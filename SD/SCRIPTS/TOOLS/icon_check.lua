-- /SCRIPTS/TOOLS/lvgl_scan.lua
-- Manueller Icon Scanner mit PAGE-Tasten Support

local function codeToUTF8(c)
    local b1 = 0xE0 + math.floor(c / 4096)
    local b2 = 0x80 + math.floor((c % 4096) / 64)
    local b3 = 0x80 + (c % 64)
    return string.char(b1, b2, b3)
end

local function run(event)
    -- Globale Variable für den aktuellen Bereich (persistent über Aufrufe hinweg)
    if not current_base then current_base = 0xF000 end

    -- Layout Konstanten
    local COLS = 5
    local ROWS = 4
    local ITEMS_PER_PAGE = COLS * ROWS

    -- Helper zum Aktualisieren der Ansicht (wird unten definiert)
    -- Wir definieren sie hier vor, damit wir sie im Event-Loop nutzen können
    local update_view_func = nil 

    -- Initialisierung der UI (nur einmal)
    if not created then
        created = true
        lvgl.clear()
        
        local gap = 2
        local btn_w = math.floor((LCD_W - 10 - (gap * (COLS-1))) / COLS)
        local btn_h = 45

        -- 1. Hauptseite
        local pg = lvgl.page({
            title = "Icon Scanner",
            flexFlow = lvgl.FLOW_COLUMN,
            padAll = 5,
            back = function() return 1 end
        })

        -- 2. Status Label
        local status_label = pg:label({
            text = "Init...",
            align = lvgl.TEXT_ALIGN_CENTER,
            w = LCD_W
        })

        -- 3. Grid Container
        local grid = pg:box({
            w = LCD_W,
            h = (ROWS * (btn_h + gap)) + 10,
            borderW = 0, bgOpa = 0, padAll = 0,
        })

        -- UI Elemente Pool erstellen
        ui_elements = {} -- Global für dieses Skript, damit update_view drauf zugreifen kann
        for i = 1, ITEMS_PER_PAGE do
            local idx = i - 1
            local col = idx % COLS
            local row = math.floor(idx / COLS)

            local btn = grid:button({
                x = (col * (btn_w + gap)),
                y = (row * (btn_h + gap)),
                w = btn_w, h = btn_h,
                text = "", 
                clickable = false
            })
            table.insert(ui_elements, btn)
        end

        -- 4. Navigation (Touch Buttons)
        local nav_box = pg:box({
            w = LCD_W, h = 50, borderW = 0, bgOpa = 0,
            flexFlow = lvgl.FLOW_ROW
        })

        -- Logik Funktionen
        function prevPage()
            current_base = current_base - ITEMS_PER_PAGE
            if current_base < 0xF000 then current_base = 0xF000 end
            if update_view_func then update_view_func() end
        end

        function nextPage()
            current_base = current_base + ITEMS_PER_PAGE
            if update_view_func then update_view_func() end
        end

        -- Funktion zum Neuzeichnen der Inhalte
        update_view_func = function()
            status_label:set({ text = string.format("Bereich: %X - %X", current_base, current_base + ITEMS_PER_PAGE - 1) })
            
            for i = 1, ITEMS_PER_PAGE do
                local code = current_base + (i - 1)
                local char = codeToUTF8(code)
                local hex_str = string.format("%X", code)
                
                local btn = ui_elements[i]
                if btn then
                    btn:set({ text = char .. "\n" .. hex_str })
                end
            end
        end

        -- Touch Buttons erstellen
        nav_box:button({
            text = "<< Back (Page<)",
            w = (LCD_W / 2) - 10,
            x = 0,
            press = prevPage
        })

        nav_box:button({
            text = "Next (Page>) >>",
            w = (LCD_W / 2) - 10,
            x = (LCD_W / 2) + 5,
            press = nextPage
        })

        -- Erster Aufruf
        update_view_func()
    end

    -- -----------------------------------------------------------
    -- PHYSISCHE TASTEN ABFRAGE (im Event Loop)
    -- -----------------------------------------------------------
    
    -- Prüfen auf PAGE Tasten (Event Codes variieren je nach Radio/Version, 
    -- aber EVT_VIRTUAL_... sind meist der Standard für Tools)
    
    if event == EVT_VIRTUAL_NEXT_PAGE or event == EVT_PAGE_DN then
        nextPage()
    elseif event == EVT_VIRTUAL_PREV_PAGE or event == EVT_PAGE_UP then
        prevPage()
    end

    return 0
end

-- Hier nun mit dem geforderten Flag
return { run=run, lvgl=true }