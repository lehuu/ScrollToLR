return {
	
	LrSdkVersion = 6.0,
	LrSdkMinimumVersion = 6.0, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'com.adobe.lightroom.sdk.scroll2Lr',

	LrPluginName = "Scroll2Lr",
	LrInitPlugin = "InitPlugin.lua",
	LrShutdownPlugin = "ShutdownPlugin.lua",
	LrShutdownApp = "ShutdownApp.lua",
	LrEnablePlugin = "EnablePlugin.lua",
	LrDisablePlugin = "DisablePlugin.lua",

	LrForceInitPlugin = true,

	LrHelpMenuItems =
	{
		{
			title = "Settings",
			file = "Settings.lua",
		},
	},

	VERSION = { major=0, minor=1, revision=0 },
}


	
