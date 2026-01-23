chdir("/SCRIPTS/RF2_widget")

local run = nil
local scriptsCompiled = loadScript("COMPILE/scripts_compiled.lua")
local useLvgl = false
local logLib = assert(loadScript("lib/log.lua"))()
local app_name = "RF2_tool"
logLib.init(app_name)
local log = logLib.log

if scriptsCompiled then
    log("Starting RF2_tool")
    local canUseLvgl = assert(loadScript("lib/canUseLvgl.lua"))()
    if canUseLvgl then
        useLvgl = true
    end
    local langLib = assert(loadScript("lib/language.lua"))()
    local i18n = langLib.getTranslations()

    if useLvgl then
        -- Placeholder for LVGL UI
        log("LVGL UI is not yet implemented, using placeholder.")
        local initialized = false
        run = function(event)
            if not initialized then
                lvgl.clear()
                lvgl.label({
                    text = "LVGL UI should run here.",
                    align = ALIGN_CENTER,
                })
                initialized = true
            end
            if event == EVT_VIRTUAL_EXIT then return 1 end
            return 0
        end
    else
        log("Loading not supported UI.")
        run = assert(loadScript("tool/ui_notSupported.lua"))(i18n)
    end
else
    log("Loading compile script.")
    run = assert(loadScript("COMPILE/compile.lua"))()
    collectgarbage()
end

return { run = run, useLvgl = useLvgl }