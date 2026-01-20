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
        {"textColor"    , COLOR , WHITE },
        {"enableAudio"     , BOOL  ,   1         }, -- 0=disable audio announcements, 1=enable audio announcements
        {"every10percent", BOOL  ,   1         }, -- 0=disable 10% capacity announce, 1=enable 10% capacity announce
        {"enableHaptic"     , BOOL  ,   1         }, -- 0=disable haptic announcements, 1=enable haptic announcements
        {"auroprofile", CHOICE, 8 , {"Rate Profile 1", "Rate Profile 2", "Rate Profile 3", "Rate Profile 4", "Rate Profile 5", "Rate Profile 6", "Rate Profile 7", "Rate Profile 8", "Disabled"} }, -- auto switch rate profile based on throttle position
        
    },

    translate = function(name)
        -- This function is called by the system to get the display name for an option.
        return translations[name]
    end
}

return M
