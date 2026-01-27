-- This script is executed once when loaded by the main tool.
-- It prepares the text and returns the 'run' function for the tool.

local i18n_table = _G.rfsuite and _G.rfsuite.i18n
local text1, text2

if type(i18n_table) == "table" then
    text1 = i18n_table.radioNotSupported or "*Radio not supported!"
    text2 = i18n_table.needGraphicalRadio or "*Need graphical radio"
else
    text1 = "*Radio not supported!"
    text2 = "*Need graphical radio"
    if _G.rfsuite and _G.rfsuite.log then
        _G.rfsuite.log("Warning: Global rfsuite.i18n was not a table in ui_notSupported.lua, type was: %s", type(i18n_table))
    end
end
rfsuite.log("Displaying not supported UI (LVGL): '%s' / '%s'", text1, text2)

local initialized = false

local function run(event)
    -- In LVGL mode, UI elements are created once and then redrawn automatically.
    if not initialized then
        initialized = true
        lvgl.clear()

        lvgl.label({
            align = ALIGN_CENTER,
            y = 100,
            text = text1
        })

        lvgl.label({
            align = ALIGN_CENTER,
            y = 130,
            text = text2
        })
    end

    if event == EVT_VIRTUAL_EXIT then
        return 1 -- A non-zero value exits the tool
    else
        return 0
    end
end

return run