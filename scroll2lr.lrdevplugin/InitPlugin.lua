require 'Preferences'

if nil == plugin.prefs.loggingEnabled then plugin.prefs.loggingEnabled = false end

initLogger(plugin.prefs.loggingEnabled)
trace('Enabling Plugin')