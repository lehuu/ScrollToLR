plugin =
{
    name = 'Scroll2Lr',
    --loggingEnabled
    prefs = import 'LrPrefs'.prefsForPlugin()
}
local logger = import 'LrLogger'(plugin.name)

trace = logger:quickf('trace')

function initLogger(isEnabled) -- true or false
    if plugin.prefs.loggingEnabled == isEnabled then return end
    
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