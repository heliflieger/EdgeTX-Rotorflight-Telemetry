local args = {...}
local log = args[1]
local app_name = args[2]

local M = {}
M.m_log = m_log
M.app_name = app_name
M.tele_src_name = nil
M.tele_src_id = nil

local getTime = getTime
local lcd = lcd

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}
M.FS = FS
M.FONT_LIST = {FS.FONT_6, FS.FONT_8, FS.FONT_12, FS.FONT_16, FS.FONT_38}

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

function M.periodicInit()
    local t = {
        startTime = -1,
        durationMili = -1
    }
    return t
end

function M.periodicStart(t, durationMili)
    t.startTime = getTime();
    t.durationMili = durationMili;
end

function M.periodicHasPassed(t, show_log)
    -- not started yet
    if (t.durationMili <= 0) then
        return false;
    end

    local elapsed = getTime() - t.startTime;
    --log('elapsed: %d (t.durationMili: %d)', elapsed, t.durationMili)
    if show_log == true then
        log('elapsed: %0.1f/%0.1f sec', elapsed/100, t.durationMili/1000)
    end
    local elapsedMili = elapsed * 10;
    if (elapsedMili < t.durationMili) then
        return false;
    end
    return true;
end

function M.periodicGetElapsedTime(t, show_log)
    local elapsed = getTime() - t.startTime;
    local elapsedMili = elapsed * 10;
    if show_log == true then
        log('elapsed: %0.1f/%0.1f sec', elapsed/100, t.durationMili/1000)
    end
    return elapsedMili;
end

function M.periodicReset(t)
    t.startTime = getTime();
    --log("periodicReset()");
    M.periodicGetElapsedTime(t)
end


------------------------------------------------------------------------------------------------------



function M.getFontIndex(fontSize, defaultFontSize)
    for i = 1, #M.FONT_LIST do
        -- log("M.FONT_SIZES[%d]: %d (%d)", i, M.FONT_LIST[i], fontSize)
        if M.FONT_LIST[i] == fontSize then
            return i
        end
    end
    return defaultFontSize
end

------------------------------------------------------------------------------------------------------

function M.lcdSizeTextFixed(txt, font_size)
    local ts_w, ts_h = lcd.sizeText(txt, font_size)

    local v_offset = 0
    if font_size == FS.FONT_38 then
        v_offset = -6
        ts_h = 52
        ts_w=ts_w-3
    elseif font_size == FS.FONT_16 then
        v_offset = -6
        ts_h = 28
    elseif font_size == FS.FONT_12 then
        v_offset = -5
        ts_h = 20
    elseif font_size == FS.FONT_8 then
        v_offset = -3
        ts_h = 15
    elseif font_size == FS.FONT_6 then
        v_offset = -2
        ts_h = 14
    end
    return ts_w, ts_h, v_offset
end



------------------------------------------------------------------------------------------------------
function M.drawText(x, y, text, font_size, text_color, bg_color)
    local ts_w, ts_h, v_offset = M.lcdSizeTextFixed(text, font_size)
    lcd.drawRectangle(x, y, ts_w, ts_h, BLUE)
    lcd.drawText(x, y + v_offset, text, font_size + text_color)
    return ts_w, ts_h, v_offset
end



M.isFileExist = function(file_name)
    -- log("is_file_exist()")
    local hFile = io.open(file_name, "r")
    if hFile == nil then
        -- log("file not exist - %s", file_name)
        return false
    end
    io.close(hFile)
    -- log("file exist - %s", file_name)
    return true
end

return M
