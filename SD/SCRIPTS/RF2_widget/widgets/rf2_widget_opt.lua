<<<<<<< Updated upstream
=======
local langLib = assert(loadScript("/SCRIPTS/RF2_widget/lib/language.lua"))()
local translations = langLib.getTranslations()

>>>>>>> Stashed changes
local M = {

    options = {
        {"showTotalVoltage", BOOL  , 0      }, -- 0=Show as average Lipo cell level, 1=show the total voltage (voltage as is)
        {"guiStyle"     , CHOICE, 2 , {"1-Fancy", "2-Modern"} },
        {"currTop"      , VALUE , 150 , 40, 300 },
        {"tempTop"      , VALUE ,  90 , 30, 150 },
        {"textColor"    , COLOR , WHITE },
        {"enableAudio"     , BOOL  ,   1         }, -- 0=disable audio announcements, 1=enable audio announcements
        {"enableHaptic"     , BOOL  ,   1         }, -- 0=disable haptic announcements, 1=enable haptic announcements
        {"auroprofile", CHOICE, 8 , {"Rate Profile 1", "Rate Profile 2", "Rate Profile 3", "Rate Profile 4", "Rate Profile 5", "Rate Profile 6", "Rate Profile 7", "Rate Profile 8", "Disabled"} }, -- auto switch rate profile based on throttle position
    },

    translate = function(name)
<<<<<<< Updated upstream
        local translations = {
            showTotalVoltage="Show Total Voltage",
            guiStyle="GUI Style",
            currTop="Max Current",
            tempTop="Max ESC Temp",
            textColor="Text Color",
            enableAudio="Enable Audio Announcements",
            enableHaptic="Enable Haptic Announcements",
            auroprofile="Select the rate profile for autorotation",
        }
        return translations[name]
=======
        -- This function is called by the system to get the display name for an option.
        return translations[name] or name
>>>>>>> Stashed changes
    end

}

return M
