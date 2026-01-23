local M = {}

local base_path = "/SCRIPTS/RF2_widget/lang/"

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

---
-- Loads the translation file for the current system language.
-- It falls back to English ('EN') if the system language file is not found,
-- and then to an empty table if English is also not found.
-- @return table The translations table.
function M.getTranslations()
    local settings = getGeneralSettings()
    local lang = settings.language
    return loadTranslations(lang) or loadTranslations("EN") or {}
end

return M