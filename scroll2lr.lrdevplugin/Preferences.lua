plugin = {
    name = 'Scroll2Lr',
    -- loggingEnabled
    prefs = import'LrPrefs'.prefsForPlugin()
}
local logger = import 'LrLogger'(plugin.name)

function initLogger(isEnabled) -- true or false
    plugin.prefs.loggingEnabled = isEnabled

    if isEnabled then
        logger:enable('logfile')
        logger:trace("--------------------------------------------------")
        logger:trace("Enabling Log")
    else
        logger:trace("Disabling Log")
        logger:trace("--------------------------------------------------")
        logger:disable()
    end
end

function outputToLog(message)
    logger:tracef(message)
end
