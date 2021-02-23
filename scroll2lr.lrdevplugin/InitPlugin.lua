local LrDevelopController = import 'LrDevelopController'
local LrFunctionContext = import "LrFunctionContext"
local LrSocket = import "LrSocket"
local LrTasks = import "LrTasks"
local LrApplication = import 'LrApplication'
require 'Preferences'

if nil == plugin.prefs.loggingEnabled then
    plugin.prefs.loggingEnabled = false
end

initLogger(plugin.prefs.loggingEnabled)
outputToLog('Initializing Plugin')

----------------------------------------------------------------------------------------------------------------------

local sender
local senderPort = 58702
local senderConnected = false
local senderShutdown = false

local function createSenderSocket(context)

    outputToLog("Creating sender socket")

    sender = LrSocket.bind {
        functionContext = context,
        port = senderPort,
        mode = "send",
        plugin = _PLUGIN,

        onConnecting = function(socket, port)
            outputToLog('Sender socket connecting: ' .. port)
        end,

        onConnected = function(socket, port)
            outputToLog('Sender socket connected: ' .. port)
            senderConnected = true
        end,

        onClosed = function(socket)
            outputToLog('Sender socket closed: ' .. senderPort)
            senderConnected = false
        end,

        onError = function(socket, err)
            outputToLog('Sender socket ' .. senderPort .. ' error: ' .. err)
            senderConnected = false

            if senderShutdown then
                outputToLog('Sender socket is shut down: ' .. senderPort)
                return
            end

            socket:reconnect()
        end
    }

    return sender
end

function sendMessage(message)
    LrTasks.startAsyncTaskWithoutErrorHandler(function()
        outputToLog('Sending message: "' .. message .. '"')
        sender:send(message .. '\n')
        outputToLog('Sent')
    end, 'sendMessage')
end

----------------------------------------------------------------------------------------------------------------------

local receiverPort = 58701
local receiverConnected = false
local receiverShutdown = false

local function createReceiverSocket(context)

    outputToLog('Creating receiver socket')

    local receiver = LrSocket.bind {
        functionContext = context,
        port = receiverPort,
        mode = "receive",
        plugin = _PLUGIN,

        onConnecting = function(socket, port)
            outputToLog('Receiver socket connecting: ' .. port)
        end,

        onConnected = function(socket, port)
            outputToLog('Receiver socket connected: ' .. port)
            receiverConnected = true

            createSenderSocket(context)
        end,

        onClosed = function(socket)
            outputToLog('Receiver socket closed: ' .. receiverPort)
            receiverConnected = false

            sender:close()

            if not receiverShutdown then
                socket:reconnect()
            end
        end,

        onError = function(socket, err)
            if receiverShutdown then
                outputToLog('Receiver socket is shut down: ' .. receiverPort)
                return
            end

            receiverConnected = false

            if err ~= 'timeout' then
                outputToLog('Receiver socket ' .. receiverPort .. ' error: ' .. err)
            end
            socket:reconnect()

        end,

        onMessage = function(socket, message)
            if type(message) ~= "string" then
                outputToLog('Receiver socket message type ' .. type(message))
            end

            if message == 'ping' then
                sendMessage('pong')
            else
                local split = message:find('|', 1, true)
                local param = message:sub(1, split - 1)
                local value = message:sub(split + 1)
                outputToLog(message)
                return
                -- LrTasks.startAsyncTaskWithoutErrorHandler(function()
                --     handleMessage(messageId, functionName, functionParams)
                -- end, 'handleMessage')
            end
        end
    }

    return receiver
end

----------------------------------------------------------------------------------------------------------------------

LrTasks.startAsyncTask(function()

    LrFunctionContext.callWithContext('scroll2lr', function(context)

        local version = LrApplication.versionTable()
        if version['major'] < 9 then
            outputToLog('Not initializing plugin for Lightroom version ' .. LrApplication.versionString())
            return
        end

        outputToLog('Starting sockets')

        local receiver = createReceiverSocket(context)

        plugin.running = true
        while plugin.running do
            LrTasks.sleep(0.25) -- 250ms
        end

        outputToLog('Stopping sockets')

        receiverShutdown = true
        senderShutdown = true

        if receiverConnected then
            receiver:close()
        end

        outputToLog('Stopped sockets')

        plugin.shutdown = true

    end)

end)
