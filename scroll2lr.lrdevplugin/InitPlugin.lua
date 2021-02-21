local LrApplication = import 'LrApplication'
local LrApplicationView = import 'LrApplicationView'
local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrFunctionContext = import "LrFunctionContext"
local LrPathUtils = import 'LrPathUtils'
local LrSocket = import "LrSocket"
local LrTasks = import "LrTasks"
require 'Preferences'

if nil == plugin.prefs.loggingEnabled then plugin.prefs.loggingEnabled = false end

initLogger(plugin.prefs.loggingEnabled)
print('Initializing Plugin')

----------------------------------------------------------------------------------------------------------------------

local SEND_PORT        = 58764
local sender
local senderConnected = false
local senderShutdown = false

local function createSenderSocket(context)

    print("Creating sender socket")

    local sender = LrSocket.bind
    {
        functionContext = context,
        port = SEND_PORT,
        mode = "send",
        plugin = _PLUGIN,

        onConnecting = function(socket, port)
            print('Sender socket connecting: ' .. port)
        end,

        onConnected = function(socket, port)
            print('Sender socket connected: ' .. port)
            senderConnected = true
        end,

        onClosed = function(socket)
            print('Sender socket closed: ' .. SEND_PORT)
            senderConnected = false
        end,

        onError = function(socket, err)
            print('Sender socket %d error: %s', SEND_PORT, err)
            senderConnected = false

            if senderShutdown then
                print('Sender socket is shut down: ' .. SEND_PORT)
                return
            end

            socket:reconnect()
        end,
    }

    return sender
end

function sendMessage(messageId, message)
    LrTasks.startAsyncTaskWithoutErrorHandler(function ()
        print('Sending message "%s": "%s"', messageId, message)
        sender:send(messageId .. '|' .. message .. '\n')
        print('Sent')
    end, 'sendMessage')
end

function sendEvent(eventName, eventParameter)
    sendMessage("0", eventName .. '|' .. eventParameter)
end

----------------------------------------------------------------------------------------------------------------------

local RECEIVE_PORT     = 58763
local receiverConnected = false
local receiverShutdown = false

local function createReceiverSocket(context)

    print('Creating receiver socket')

    local receiver = LrSocket.bind
    {
        functionContext = context,
        port = RECEIVE_PORT,
        mode = "receive",
        plugin = _PLUGIN,

        onConnecting = function(socket, port)
            print('Receiver socket connecting: ' .. port)
        end,

        onConnected = function(socket, port)
            print('Receiver socket connected: ' .. port)
            receiverConnected = true

            sender = createSenderSocket(context)
        end,

        onClosed = function(socket)
            print('Receiver socket closed: ' .. RECEIVE_PORT)
            receiverConnected = false

            sender:close()

            if receiverShutdown == false then
                socket:reconnect()
            end
        end,

        onError = function(socket, err)
            if receiverShutdown then
                print('Receiver socket is shut down: ' .. RECEIVE_PORT)
                return
            end

            receiverConnected = false

            print('Receiver socket %d error: %s', RECEIVE_PORT, err)
            socket:reconnect()
        end,

        onMessage = function(socket, message)
            if type(message) ~= "string" then
                print('Receiver socket message type ' .. type(message))
            end

            local messageId, message = string.split(message, '|')
            local functionName, functionParams = string.split(message, '|')

            print('Function "%s(%s)"', functionName, functionParams)
            if 'ping' == functionName then
                sendMessage(messageId, 'ok')
            else
                print('TODO Handle Message')
            end
        end,
    }

    return receiver
end

----------------------------------------------------------------------------------------------------------------------

LrTasks.startAsyncTask(function()
    
    LrFunctionContext.callWithContext('scroll2lr_remote', function(context)

        local version = LrApplication.versionTable()
        if version['major'] < 10 then
            print('Not initializing plugin for Lightroom version ' .. LrApplication.versionString())
            return
        end

        print('Starting sockets')

        local receiver = createReceiverSocket(context)

    end)

end)
