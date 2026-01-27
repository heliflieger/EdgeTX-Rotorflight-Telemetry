local langLib = assert(loadScript("/SCRIPTS/RF2_widget/lib/language.lua"))()
local translations = langLib.getTranslations()

local M = {

    options = {
        {"textColor"    , COLOR , WHITE },
        {"enableAudio"     , BOOL  ,   1         }, -- 0=disable audio announcements, 1=enable audio announcements
        {"every10percent", BOOL  ,   1         }, -- 0=disable 10% capacity announce, 1=enable 10% capacity announce
        {"enableHaptic"     , BOOL  ,   1         }, -- 0=disable haptic announcements, 1=enable haptic announcements
        {"auroprofile", CHOICE, 8 , {"Rate Profile 1", "Rate Profile 2", "Rate Profile 3", "Rate Profile 4", "Rate Profile 5", "Rate Profile 6", "Rate Profile 7", "Rate Profile 8", "Disabled"} }, -- auto switch rate profile based on throttle position
    },

    translate = function(name)
        -- This function is called by the system to get the display name for an option.
        return translations[name] or name
    end

}

return M
