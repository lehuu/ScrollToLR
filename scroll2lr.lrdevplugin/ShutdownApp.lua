require 'Preferences'

local function shutdownFunction(doneFunction, progressFunction)
    progressFunction(0, 'Shutdown started')
    outputToLog('Shutting Down App')

    if SCROLL2LR and SCROLL2LR.RUNNING then
        SCROLL2LR.RUNNING = false
        if SCROLL2LR.CLIENT then
            SCROLL2LR.CLIENT:close()
        end
        if SCROLL2LR.SERVER then
            SCROLL2LR.SERVER:close()
        end
    end
    outputToLog('Shutting Down Completed')
    progressFunction(1, 'Shutdown finished')
    doneFunction()
end

return {
    LrShutdownFunction = shutdownFunction
}
