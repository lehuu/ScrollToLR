require 'Preferences'

if nil == plugin.prefs.loggingEnabled then plugin.prefs.loggingEnabled = false end

initLogger(plugin.prefs.loggingEnabled)
print('Initializing Plugin')