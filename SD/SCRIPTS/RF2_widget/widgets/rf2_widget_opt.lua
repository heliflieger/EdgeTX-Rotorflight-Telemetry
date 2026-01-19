local settings = getGeneralSettings()
local lang = settings.language
local base_path = "/SCRIPTS/RF2_widget/lang/"
local app_name = "RF2_widget"

local function loadTranslations(l)
    local file = base_path .. l .. ".lua"
    local chunk, err = loadScript(file)
    if not chunk then
        -- It's normal for a language file not to exist, so we don't log an error.
        -- The fallback mechanism will handle it.
        return nil
    end
    local ok, result = pcall(chunk)
    if not ok then
        return nil
    end
    return result
end

-- 3. Zuweisung (Systemsprache -> Englisch -> Leere Tabelle als Schutz)
local translations = loadTranslations(lang) or loadTranslations("EN") or {}

local M = {

    options = {
        {"showTotalVoltage", BOOL  , 0      }, -- 0=Show as average Lipo cell level, 1=show the total voltage (voltage as is)
        {"guiStyle"     , CHOICE, 2 , {"1-Fancy", "2-Modern"} },
        {"currTop"      , VALUE , 150 , 40, 300 },
        {"tempTop"      , VALUE ,  90 , 30, 150 },
        {"textColor"    , COLOR , WHITE },
        {"enableAudio"     , BOOL  ,   1         }, -- 0=disable audio announcements, 1=enable audio announcements
        {"enableHaptic"     , BOOL  ,   1         }, -- 0=disable haptic announcements, 1=enable haptic announcements
        {"auroprofile", CHOICE, 8 , {"Rate Profile 1", "Rate Profile 2", "Rate Profile 3", "Rate Profile 4", "Rate rofile 5", "Rate Profile 6", "Rate Profile 7", "Rate Profile 8", "Disabled"} }, -- auto switch rate profile based on throttle position
        {"every10percent", BOOL  ,   1         }, -- 0=disable 10% capacity announce, 1=enable 10% capacity announce
    },

    translate = function(name)
        -- This function is called by the system to get the display name for an option.
        return translations[name]
    end
}

return M
