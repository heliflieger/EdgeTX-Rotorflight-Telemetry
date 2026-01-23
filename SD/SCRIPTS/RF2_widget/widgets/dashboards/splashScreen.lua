local M = {}

-- Draw a filled rounded rectangle using primitives (no alpha blending).
-- r is corner radius in pixels.
local function drawFilledRoundRect(x, y, w, h, r, parent)
    -- Round inputs once (avoid float leakage)
    x = math.floor((x or 0) + 0.5)
    y = math.floor((y or 0) + 0.5)
    w = math.floor((w or 0) + 0.5)
    h = math.floor((h or 0) + 0.5)

    if w <= 0 or h <= 0 then return end

    r = math.floor((r or 0) + 0.5)
    r = math.max(0, math.min(r, math.floor(math.min(w, h) / 2)))

    --if r <= 0 or not lcd.drawFilledCircle then
    --    lvgl.rectangle([parent], {settings})
    --    lcd.drawFilledRectangle(x, y, w, h)
    --    return
    --end

    -- Inclusive bounds (last pixel)
    local x2 = x + w - 1
    local y2 = y + h - 1

    -- Rectangles (pixel-count widths)
    lvgl.rectangle([parent], {settings})
    lcd.drawFilledRectangle(x + r, y, w - 2 * r, h)            -- center
    lcd.drawFilledRectangle(x, y + r, r, h - 2 * r)            -- left
    lcd.drawFilledRectangle(x2 - r + 1, y + r, r, h - 2 * r)   -- right

    -- Corner circle centers (align to inclusive bounds)
    local cxL = x + r
    local cxR = x2 - r
    local cyT = y + r
    local cyB = y2 - r

    lcd.drawFilledCircle(cxL, cyT + 0.05, r)
    lcd.drawFilledCircle(cxR, cyT + 0.05, r)
    lcd.drawFilledCircle(cxL, cyB + 0.05, r)
    lcd.drawFilledCircle(cxR, cyB + 0.05, r)
end


M.build_ui = function(wgt)
    lvgl.clear()
    local panelW = math.floor(LCD_W * (opts.panelWidthRatio or 0.7))
    local panelH = math.floor(LCD_H * (opts.panelHeightRatio or 0.6))
    local panelX = math.floor(x + (LCD_W - panelW) / 2 + 0.5)
    local panelY = math.floor(y + (LCD_H - panelH) / 2 + 0.5)
    local cornerR = opts.cornerR or math.floor(math.min(panelW, panelH) * 0.14)
    

    local bMain = lvgl.box({x=0, y=0})
    bMain:label({text = "Loading...", x=140,y=10, color=WHITE, font=XXLSIZE})

    drawFilledRoundRect(panelX, panelY, panelW, panelH, cornerR, bMain)

end

return M

--- End of splashScreen.lua