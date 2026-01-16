local app_name = ...

local M = {}
M.app_name = app_name

local lcd = lcd

-- better font names
local FONT_38 = XXLSIZE -- 38px
local FONT_16 = DBLSIZE -- 16px
local FONT_12 = MIDSIZE -- 12px
local FONT_8 = 0 -- Default 8px
local FONT_6 = SMLSIZE -- 6px

local FONT_LIST = {FONT_6, FONT_8, FONT_12, FONT_16, FONT_38}

------------------------------------------------------------------------------------------------------
function M.lcdSizeTextFixed(txt, font_size)
    local ts_w, ts_h = lcd.sizeText(txt, font_size)

    local v_offset = 0
    if font_size == FONT_38 then
        v_offset = -15
    elseif font_size == FONT_16 then
        v_offset = -8
    elseif font_size == FONT_12 then
        v_offset = -6
    elseif font_size == FONT_8 then
        v_offset = -4
    elseif font_size == FONT_6 then
        v_offset = -3
    end
    return ts_w, ts_h +2*v_offset, v_offset
end

------------------------------------------------------------------------------------------------------
function M.drawText(x, y, text, font_size, text_color, bg_color)
    local ts_w, ts_h, v_offset = M.lcdSizeTextFixed(text, font_size)
    lcd.drawRectangle(x, y, ts_w, ts_h, BLUE)
    lcd.drawText(x, y + v_offset, text, font_size + text_color)
    return ts_w, ts_h, v_offset
end

function M.drawBadgedText(txt, txtX, txtY, font_size, text_color, bg_color)
    local ts_w, ts_h, v_offset = M.lcdSizeTextFixed(txt, font_size)
    local v_space = 2
    local bdg_h = v_space + ts_h + v_space
    local r = bdg_h / 2
    lcd.drawFilledCircle(txtX , txtY + r, r, bg_color)
    lcd.drawFilledCircle(txtX + ts_w , txtY + r, r, bg_color)
    lcd.drawFilledRectangle(txtX, txtY , ts_w, bdg_h, bg_color)

    lcd.drawText(txtX, txtY + v_offset + v_space, txt, font_size + text_color)

    --lcd.drawRectangle(txtX, txtY , ts_w, bdg_h, RED) -- dbg
end

function M.drawBadgedTextCenter(txt, txtX, txtY, font_size, text_color, bg_color)
    local ts_w, ts_h, v_offset = M.lcdSizeTextFixed(txt, font_size)
    local r = ts_h / 2
    local x = txtX - ts_w/2
    local y = txtY - ts_h/2
    lcd.drawFilledCircle(x + r * 0.3, y + r, r, bg_color)
    lcd.drawFilledCircle(x - r * 0.3 + ts_w , y + r, r, bg_color)
    lcd.drawFilledRectangle(x, y, ts_w, ts_h, bg_color)

    lcd.drawText(x, y + v_offset, txt, font_size + text_color)

    -- dbg
    --lcd.drawRectangle(x, y , ts_w, ts_h, RED) -- dbg
    --lcd.drawLine(txtX-30, txtY, txtX+30, txtY, SOLID, RED) -- dbg
    --lcd.drawLine(txtX, txtY-20, txtX, txtY+20, SOLID, RED) -- dbg
end

------------------------------------------------------------------------------------------------------

return M
