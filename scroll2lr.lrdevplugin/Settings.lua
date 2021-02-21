-- Access the Lightroom SDK namespaces.
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
require 'Preferences'

local function showCustomDialog()

	LrFunctionContext.callWithContext( "showCustomDialog", function( context )
	
	    local f = LrView.osFactory()
		
	    local props = LrBinding.makePropertyTable( context )
	    props.loggingEnabled = plugin.prefs.loggingEnabled

        local function loggingUpdated()
			initLogger(props.loggingEnabled)
		end

		props:addObserver( "loggingEnabled", loggingUpdated )


	    -- Create the contents for the dialog.
	    local c = f:row {
	
		    -- Bind the table to the view.  This enables controls to be bound
		    -- to the named field of the 'props' table.
		    
		    bind_to_object = props,
				
		    -- Add a checkbox and an edit_field.
		    
		    f:checkbox {
			    title = "Enable Log",
			    value = LrView.bind( "loggingEnabled" ),
		    },
	    }
	
	    LrDialogs.presentModalDialog {
			    title = "Settings",
			    contents = c
		    }


	end) -- end main function

end


-- Now display the dialogs.
showCustomDialog()