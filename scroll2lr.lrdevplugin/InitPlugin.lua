local LrDevelopController = import 'LrDevelopController'
local LrFunctionContext = import "LrFunctionContext"
local LrSocket = import "LrSocket"
local LrTasks = import "LrTasks"
require 'Preferences'

if nil == plugin.prefs.loggingEnabled then
    plugin.prefs.loggingEnabled = false
end

initLogger(plugin.prefs.loggingEnabled)
print('Initializing Plugin')

----------------------------------------------------------------------------------------------------------------------

LrTasks.startAsyncTask(function()

    -- global variables
    SCROLL2LR = {
        SERVER = {},
        CLIENT = {},
        RUNNING = true
    } -- non-local but in SCROLL2LR namespace
    -- local variables
    local LastParam = ''
    local UpdateParamPickup, UpdateParamNoPickup, UpdateParam
    local sendIsConnected = false -- tell whether send socket is up or not
    -- local constants--may edit these to change program behaviors
    local RECEIVE_PORT = 58701
    local SEND_PORT = 58702

    LrFunctionContext.callWithContext('socket_remote', function(context)

        -- wrapped in function so can be called when connection lost
        local function startServer(senderContext)
            SCROLL2LR.SERVER = LrSocket.bind {
                functionContext = senderContext,
                plugin = _PLUGIN,
                port = SEND_PORT,
                mode = 'send',
                onClosed = function()
                    sendIsConnected = false
                    print('Sender closed: ' .. SEND_PORT)
                end,
                onConnected = function()
                    sendIsConnected = true
                    print('Sender connected: ' .. SEND_PORT)
                end,
                onError = function(socket, err)
                    sendIsConnected = false
                    print('Sender error: ' .. err)
                    if SCROLL2LR.RUNNING then --
                        socket:reconnect()
                    end
                end
            }
        end

        SCROLL2LR.CLIENT = LrSocket.bind {
            functionContext = context,
            plugin = _PLUGIN,
            port = RECEIVE_PORT,
            mode = 'receive',
            onConnected = function(socket, port)
                print('Receiver connected: ' .. RECEIVE_PORT)
            end,
            onMessage = function(_, message) -- message processor
                print('Recever received message: ' .. RECEIVE_PORT)
                if type(message) == 'string' then
                    print(message)
                end
            end,
            onClosed = function(socket)
                if SCROLL2LR.RUNNING then
                    -- closed connection, allow for reconnection
                    print('Recever closed: ' .. RECEIVE_PORT)

                    socket:reconnect()
                    -- calling SERVER:reconnect causes LR to hang for some reason...
                    SCROLL2LR.SERVER:close()
                    startServer(context)
                end
            end,
            onError = function(socket, err)
                print('Recever error: ' .. err)
                if err == 'timeout' then -- reconnect if timed out
                    socket:reconnect()
                end
            end
        }

        startServer(context)

        if SCROLL2LR.RUNNING then -- didn't drop out of loop because of program termination
            while SCROLL2LR.RUNNING do -- detect halt or reload
                LrTasks.sleep(.29)
            end
        end
    end)
end)
