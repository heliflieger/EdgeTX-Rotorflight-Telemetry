-- tool/ui_dashboard.lua
-- This script builds the main dashboard UI for the tool.

local function dashboard()
    -- Load global environment
    local rfsuite = _G.rfsuite or {}
    local i18n = rfsuite.i18n or {}
    local config = rfsuite.config or {}

    -- --- FONTS ---
    -- CRITICAL: XXLSIZE often does NOT contain icons on EdgeTX!
    -- We use MIDSIZE (FONT_STD) to guarantee icons are visible.
    local FONT_STD = MIDSIZE or FONT_STD
    
    -- Path to images
    local baseDir = config.baseDir or "/SCRIPTS/TOOLS/"
    local IMG_PATH = baseDir .. "img/"

    -- Translation helper
    local function t(key, default)
        return i18n[key] or default
    end

    local initialized = false
    local should_exit = false

    local function run(event, touchState)
        if should_exit then return 1 end

        if not initialized then
            initialized = true
            lvgl.clear()

            -- 1. Define Symbols OR Image Paths
            local SYMBOL = {
                -- Standard Icons
                OK       = "\xef\x80\x8c",
                CLOSE    = "\xef\x80\x8d",
                SETTINGS = "\xef\x80\x93",
                WIFI     = "\xef\x87\xab",
                BATTERY  = "\xef\x89\x80",
                TRASH    = "\xef\x8b\xad",
                EDIT     = "\xef\x8C\x84",
                SAVE     = "\xef\x85\x9d",
                REFRESH  = "\xef\x80\xa1",
                PLAY     = "\xef\x81\x8b",
                PAUSE    = "\xef\x81\x8c",
                STOP     = "\xef\x81\x8d",
                PLUS     = "\xef\x81\xa7",
                MINUS    = "\xef\x81\xa8",
                WARNING  = "\xef\x81\xb1",
                
                LIST     = "\xef\x80\xba",
                CHART    = "\xef\x88\x81",

                -- PNG Image
                -- Ensure this file exists and is ~48x48px!
                PID      = IMG_PATH .. "pids.png",
                GEAR     = IMG_PATH .. "rf2.png"
            }

            -- 2. Menu Data
            local menu_data = {{
                title = "Configuration",
                items = {{
                    name = "PIDs",
                    icon = SYMBOL.PID -- Uses PNG
                }, {
                    name = "Rates",
                    icon = SYMBOL.REFRESH
                }, {
                    name = "Governor",
                    icon = SYMBOL.GEAR
                }, {
                    name = "Tail Rotor",
                    icon = SYMBOL.SETTINGS
                }, {
                    name = "Advanced",
                    icon = SYMBOL.EDIT
                }, {
                    name = "Hardware",
                    icon = SYMBOL.WIFI
                }}
            }, {
                title = "System",
                items = {{
                    name = "Tools",
                    icon = SYMBOL.EDIT
                }, {
                    name = "Logs",
                    icon = SYMBOL.LIST
                }, {
                    name = "Settings",
                    icon = SYMBOL.GEAR
                }, {
                    name = "Diagnostics",
                    icon = SYMBOL.WARNING
                }}
            }}

            -- Layout
            local gap = 4
            local pad_sides = 10
            local btn_w = math.floor((LCD_W - (pad_sides * 2) - (gap * 2)) / 3)
            local btn_h = 60

            -- Main Page
            local pg = lvgl.page({
                title = "Rotorflight Dashboard",
                back = function() should_exit = true end,
                backButton = true,
                flexFlow = lvgl.FLOW_COLUMN,
                flexGap = 10,
                padAll = 0 
            })

            for _, section in ipairs(menu_data) do
                -- A. Header
                local header = pg:button({
                    w = LCD_W, h = 35,
                    color = lcd.RGB(20, 20, 20), -- Almost Black
                    clickable = false,
                    borderW = 0, padAll = 0,
                })

                lvgl.label(header, {
                    text = section.title,
                    color = lcd.RGB(255, 255, 255),
                    align = lvgl.TEXT_ALIGN_CENTER,
                    w = LCD_W, y = 5 
                })

                -- B. Grid
                local cols = 3
                local rows = math.ceil(#section.items / cols)
                local grid_height = (rows * btn_h) + ((rows - 1) * gap)

                local grid = pg:box({
                    w = LCD_W, h = grid_height,
                    borderW = 0, bgOpa = 0, padAll = 0, x = 0
                })

                -- C. Buttons
                for i, item in ipairs(section.items) do
                    local idx = i - 1
                    local col = idx % cols
                    local row = math.floor(idx / cols)
                    local pos_x = pad_sides + (col * (btn_w + gap))
                    local pos_y = row * (btn_h + gap)

                    local btn = grid:button({
                        x = pos_x, y = pos_y, w = btn_w, h = btn_h,
                        color = lcd.RGB(48, 48, 48), -- Dark Grey
                        press = function() print("Pressed: " .. item.name) end
                    })

                    -- --- LOGIC: IMAGE vs COMBINED LABEL ---
                    
                    if string.find(item.icon, ".png") then
                        -- >>> CASE 1: PNG IMAGE <<<
                        
                        -- Debug: Print path to console (check Debug Output!)
                        lvgl.image(btn,{y=15, w=20, h=20, fill=false,
                            file=item.icon,
                        })             

                        -- Separate Label for Text (bottom)
                        lvgl.label(btn, {
                            text = item.name,
                           -- font = FONT_STD,
                            color = lcd.RGB(255, 255, 255), -- White
                            align = lvgl.TEXT_ALIGN_CENTER,
                            w = btn_w, 
                            x = 25,
                            y = 15,
                            clickable = false,
                        })

                    else
                        -- >>> CASE 2: FONT ICON (Integrated) <<<
                        -- We combine Icon and Name with a new line (\n)
                        -- We use FONT_STD to ensure icons are visible!
                        
                        lvgl.label(btn, {
                            text = " " .. item.icon .. " " .. item.name,
                            -- font = FONT_STD,
                            color = lcd.RGB(255, 255, 255), -- White
                            align = lvgl.TEXT_ALIGN_CENTER,
                            w = btn_w,
                            y = 15,
                            -- Centering the combined block vertically
                            clickable = false,
                            -- bgOpa = 0
                        })
                    end
                end
            end
        end

        if event == EVT_VIRTUAL_EXIT then return 1 end
        return 0
    end
    return run
end

return dashboard()