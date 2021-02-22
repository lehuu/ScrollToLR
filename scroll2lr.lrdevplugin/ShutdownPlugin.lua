require 'Preferences'

-- check if SCROLL2LR is set because if plugin fails to load in LR, reloading mechanism will fail because SCROLL2LR will be unset
if SCROLL2LR and SCROLL2LR.RUNNING then
    SCROLL2LR.RUNNING = false
    if SCROLL2LR.CLIENT then
        SCROLL2LR.CLIENT:close()
    end
    if SCROLL2LR.SERVER then
        SCROLL2LR.SERVER:close()
    end
end
outputToLog('Shutting Down Plugin')
