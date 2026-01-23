local app_name = "RF2_widget"

local VERSION = "1.0.0"

local baseDir = "/SCRIPTS/RF2_widget"
local SETTINGS_FILENAME = baseDir .. "/settings.dat"
local inSimu = string.sub(select(2,getVersion()), -4) == "simu"

local timerNumber = 1

local dashboard_styles = {
    [1] = "rf2_dashboard_fancy.lua",
    [2] = "rf2_dashboard_modern.lua",
    [3] = "rf2_dashboard_capa.lua",
}

local lastTime = 0


local wgt = {
    app_ver = VERSION,
    is_connected = false,
    isDirty = false, -- Flag to mark unsaved changes
    lastSaveTime = 0, -- Timestamp of the last save
    isInitialized = false,
    task_capa_audio = nil,
    
    values = {
        craft_name = "-------",
        timer_str = "--:--",

        vbat = -1,
        vcel = -1,
        cell_percent = -1,
        volt = -1,
        curr = 0,
        curr_max = 0,
        curr_str = "0",
        curr_max_str = "0",
        curr_percent = 0,
        curr_max_percent = 0,
        capaUsed = -1,
        capaPercent = -1,
        capaPercent_txt = "---",

        EscT = 0,
        EscT_max = 0,
        EscT_str = "0",
        EscT_max_str = "0",
        EscT_percent = 0,
        EscT_max_percent = 0,

        hspd = 0,

        rqly = 0,
        rqly_min = 0,
        rqly_str = 0,
        rqly_min_str = 0,

        -- governor_str = "-------",
        rate_profile = -1,
        rate_profile_pending = -1,
        rate_profile_announced = -1,
        rate_profile_switch_time = 0,
        pid_profile = -1,

        rescue_on = false,
        is_arm = false,
        arm_fail = false,
        arm_disable_flags_list = nil,
        arm_disable_flags_txt = "",
        

        sound_file = "---",

        img_last_name = "---",
        img_craft_name_for_image = "---",

        thr = 0,
        thr_max = 0,

        model_total_flights = nil,
        model_total_time = nil,
        model_total_time_str = "--:--",
    },

}


-- Data gathered from commercial lipo sensors
local percent_list_lipo = {
    {3.000,  0},
    {3.093,  1}, {3.196,  2}, {3.301,  3}, {3.401,  4}, {3.477,  5}, {3.544,  6}, {3.601,  7}, {3.637,  8}, {3.664,  9}, {3.679, 10},
    {3.683, 11}, {3.689, 12}, {3.692, 13}, {3.705, 14}, {3.710, 15}, {3.713, 16}, {3.715, 17}, {3.720, 18}, {3.731, 19}, {3.735, 20},
    {3.744, 21}, {3.753, 22}, {3.756, 23}, {3.758, 24}, {3.762, 25}, {3.767, 26}, {3.774, 27}, {3.780, 28}, {3.783, 29}, {3.786, 30},
    {3.789, 31}, {3.794, 32}, {3.797, 33}, {3.800, 34}, {3.802, 35}, {3.805, 36}, {3.808, 37}, {3.811, 38}, {3.815, 39}, {3.818, 40},
    {3.822, 41}, {3.825, 42}, {3.829, 43}, {3.833, 44}, {3.836, 45}, {3.840, 46}, {3.843, 47}, {3.847, 48}, {3.850, 49}, {3.854, 50},
    {3.857, 51}, {3.860, 52}, {3.863, 53}, {3.866, 54}, {3.870, 55}, {3.874, 56}, {3.879, 57}, {3.888, 58}, {3.893, 59}, {3.897, 60},
    {3.902, 61}, {3.906, 62}, {3.911, 63}, {3.918, 64}, {3.923, 65}, {3.928, 66}, {3.939, 67}, {3.943, 68}, {3.949, 69}, {3.955, 70},
    {3.961, 71}, {3.968, 72}, {3.974, 73}, {3.981, 74}, {3.987, 75}, {3.994, 76}, {4.001, 77}, {4.007, 78}, {4.014, 79}, {4.021, 80},
    {4.029, 81}, {4.036, 82}, {4.044, 83}, {4.052, 84}, {4.062, 85}, {4.074, 86}, {4.085, 87}, {4.095, 88}, {4.105, 89}, {4.111, 90},
    {4.116, 91}, {4.120, 92}, {4.125, 93}, {4.129, 94}, {4.135, 95}, {4.145, 96}, {4.176, 97}, {4.179, 98}, {4.193, 99}, {4.200,100},
}

--------------------------------------------------------------
local logLib = assert(loadScript(baseDir .. "/lib/log.lua"))()
logLib.init(app_name)
local log = logLib.log
local function clock()
    return getTime() / 100
end
--------------------------------------------------------------

-- better font size names
local FS={FONT_38=XXLSIZE,FONT_16=DBLSIZE,FONT_12=MIDSIZE,FONT_8=0,FONT_6=SMLSIZE}


-- local function tableToString(tbl)
--    if (tbl == nil) then return "---" end
--    local result = {}
--    for key, value in pairs(tbl) do
--        table.insert(result, string.format("%s: %s", tostring(key), tostring(value)))
--    end
--    return table.concat(result, ", ")
-- end

local function isFileExist(file_name)
    log("is_file_exist() file_name: %s", file_name)
    local hFile = fstat(file_name)
    if hFile == nil then
        log("file not exist - %s", file_name)
        return false
    end
    log("file exist - %s", file_name)
    return true
end

-----------------------------------------------------------------------------------------------------------------

local dbgx, dbgy = 100, 100
local function getDxByStick(stk)
    local v = getValue(stk)
    if math.abs(v) < 15 then return 0 end
    local d = math.ceil(v / 400)
    return d
end
local function dbgLayout()
    local dw = getDxByStick("ail")
    dbgx = dbgx + dw
    dbgx = math.max(0, math.min(480, dbgx))

    local dh = getDxByStick("ele")
    dbgy = dbgy - dh
    dbgy = math.max(0, math.min(272, dbgy))
    -- log("%sx%s", dbgx, dbgy)
    -- lcd.drawFilledRectangle(100,100, 70,25, GREY)
    lcd.drawText(400,0, string.format("%sx%s", dbgx, dbgy), FS.FONT_8 + WHITE)
end
local function dbg_pos()
    log("dbg_pos: %sx%s", dbgx, dbgy)
    return dbgx, dbgy
end
local function dbg_x()
    log("dbg_pos: %sx%s", dbgx, dbgy)
    return dbgx
end

local function formatTime(wgt, t1)
    local dd_raw = t1.value
    local isNegative = false
    if dd_raw < 0 then
        isNegative = true
        dd_raw = math.abs(dd_raw)
    end

    local dd = math.floor(dd_raw / 86400)
    dd_raw = dd_raw - dd * 86400
    local hh = math.floor(dd_raw / 3600)
    dd_raw = dd_raw - hh * 3600
    local mm = math.floor(dd_raw / 60)
    dd_raw = dd_raw - mm * 60
    local ss = math.floor(dd_raw)

    local time_str
    if dd == 0 and hh == 0 then
      -- less then 1 hour, 59:59
      time_str = string.format("%02d:%02d", mm, ss)

    elseif dd == 0 then
      -- lass then 24 hours, 23:59:59
      time_str = string.format("%02d:%02d:%02d", hh, mm, ss)
    else
      -- more than 24 hours
      if wgt.options.use_days == 0 then
        -- 25:59:59
        time_str = string.format("%02d:%02d:%02d", dd * 24 + hh, mm, ss)
      else
        -- 5d 23:59:59
        time_str = string.format("%dd %02d:%02d:%02d", dd, hh, mm, ss)
      end
    end
    if isNegative then
      time_str = '-' .. time_str
    end
    return time_str, isNegative
end

local build_ui = function(wgt, file_name)
    local ui_lib = assert(loadScript(baseDir .. "/widgets/dashboards/" ..file_name))()
    ui_lib.build_ui(wgt)
end

-------------------------------------------------------------------
local function close()
    lvgl.confirm({title="Exit", message="exit config?",
        confirm=(function() lvgl.exitFullScreen() end)
    })
end

-------------------------------------------------------------------

local function updateCraftName(wgt)
    wgt.values.craft_name = model.getInfo().name
end

local function updateTimeCount(wgt)
    local t1 = model.getTimer(timerNumber - 1)
    local time_str, isNegative = formatTime(wgt, t1)
    wgt.values.timer_str = time_str
end

local function updateCell(wgt)
    -- local batPercent = getValue("Bat%")
    local vbat     = getValue("Vbat")
    local vbat_min = getValue("Vbat-")

    local cell_count = getValue("Cel#")

    local vcel = cell_count > 0 and (vbat / cell_count) or 0
    local vcel_min = cell_count > 0 and (vbat_min / cell_count) or 0

    local batPercent = getValue("Bat%")
    -- log("vbat: %s, vcel: %s, BatPercent: %s", vbat, vcel, batPercent)

    wgt.values.vbat = vbat
    wgt.values.vcel = vcel
    wgt.values.cell_percent = batPercent
    wgt.values.volt = (wgt.options.showTotalVoltage==1) and vbat or vcel
    wgt.values.cellColor = (vcel < 3.7) and RED or lcd.RGB(0x00963A) --GREEN
end

local function updateCurr(wgt)
    local curr_top = wgt.options.currTop
    local val     = getValue("Curr")
    local val_max = getValue("Curr+")
    -- log("telemetery8: updateCurr:  curr: %s, curr_max: %s", curr, curr_max)

    wgt.values.curr = val
    wgt.values.curr_max = val_max
    wgt.values.curr_percent = math.min(100, math.floor(100 * (val / curr_top)))
    wgt.values.curr_max_percent = math.min(100, math.floor(100 * (val_max / curr_top)))
    wgt.values.curr_str = string.format("%dA", wgt.values.curr)
    wgt.values.curr_max_str = string.format("+%dA", wgt.values.curr_max)
end

local function updateFlyStat(wgt)
    if getFieldInfo("FlyC") then
        wgt.values.model_total_flights = getValue("FlyC")
        wgt.values.model_total_time = getValue("FlyT") or 0
        wgt.values.model_total_time_str = formatTime(wgt, {value=wgt.values.model_total_time//60})
    else
        wgt.values.model_total_flights = nil
        wgt.values.model_total_time = nil
        wgt.values.model_total_time_str = "--:--"
    end
    --wgt.values.flyd = getValue("FlyD")
end

local function updateCapa(wgt)
    wgt.values.capaUsed = getValue("Capa+")
    wgt.values.capaPercent = getValue("Bat%")
    local p = wgt.values.capaPercent
    if (p < 10) then
        wgt.values.capaColor = RED
    elseif (p < 30) then
        wgt.values.capaColor = ORANGE
    else
        wgt.values.capaColor = lcd.RGB(0x00963A) --GREEN
    end

    wgt.values.capaPercent_txt = string.format("%d%%", wgt.values.capaPercent)
end

local function updateARM(wgt)
    local arm = getValue("ARM")
    local new_state = (arm == 1 or arm == 3)

    if wgt.values.is_arm ~= new_state then
        if wgt.options.enableAudio == 1 then
            if new_state then
                playFile("armed.wav")
            else
                playFile("disarmed.wav")
            end
        end
        wgt.values.is_arm = new_state
    end
end

local function armingDisableFlagsList()
    local flags = getValue("ARMD")
    if flags == nil then
        return nil
    end


    local result = {}


    local t = ""
    for i = 0, 25 do
        if bit32.band(flags, bit32.lshift(1, i)) ~= 0 then
            if i == 0 then table.insert(result, "No Gyro") end
            if i == 1 then table.insert(result, "Failsafe is active") end
            if i == 2 then table.insert(result, "No valid receiver signal is detected") end
            if i == 3 then table.insert(result, "The FAILSAFE switch was activated") end
            if i == 4 then table.insert(result, "Box Fail Safe") end
            if i == 5 then table.insert(result, "Governor") end
            --if i == 6 then table.insert(result, "Crash Detected") end
            if i == 7 then table.insert(result, "Throttle not idle") end

            if i == 8 then table.insert(result, "Craft is not level enough") end
            if i == 9 then table.insert(result, "Arming too soon after power on") end
            if i == 10 then table.insert(result, "No Pre Arm") end
            if i == 11 then table.insert(result, "System load is too high") end
            if i == 12 then table.insert(result, "Calibrating") end
            if i == 13 then table.insert(result, "CLI is active") end
            if i == 14 then table.insert(result, "CMS Menu") end
            if i == 15 then table.insert(result, "BST") end

            if i == 16 then table.insert(result, "MSP connection is active") end
            if i == 17 then table.insert(result, "Paralyze mode activate") end
            if i == 18 then table.insert(result, "GPS") end
            if i == 19 then table.insert(result, "Resc") end
            if i == 20 then table.insert(result, "RPM Filter") end
            if i == 21 then table.insert(result, "Reboot Required") end
            if i == 22 then table.insert(result, "DSHOT Bitbang") end
            if i == 23 then table.insert(result, "Accelerometer calibration required") end

            if i == 24 then table.insert(result, "ESC/Motor Protocol not configured") end
            if i == 25 then table.insert(result, "Arm Switch") end
        end
    end
    return result
end

local function updateARMD(wgt)
    local flagList = armingDisableFlagsList()
    wgt.values.arm_disable_flags_list = flagList
    wgt.values.arm_disable_flags_txt = ""
    wgt.values.arm_fail = false

    if flagList ~= nil then
        -- log("disableFlags len: %s", #flagList)
        if (#flagList == 0) then
            wgt.values.arm_fail = false
        else
            wgt.values.arm_fail = true
            for i in pairs(flagList) do
                -- log("disableFlags: %s", i)
                -- log("disableFlags: %s", flagList[i])
                wgt.values.arm_disable_flags_txt = wgt.values.arm_disable_flags_txt .. flagList[i] .. "\n"
            end

        end
    end
end



local function updateThr(wgt)
    local val     = getValue("Thr")
    local val_max = getValue("Thr+")
    wgt.values.thr = val
    wgt.values.thr_max = val_max
end

local function updateTemperature(wgt)
    local tempTop = wgt.options.tempTop
    local val = getValue("Tesc")
    local val_max = getValue("Tesc+")
    wgt.values.EscT = val
    wgt.values.EscT_max = val_max

    wgt.values.EscT_str = string.format("%d°c", wgt.values.EscT)
    wgt.values.EscT_max_str = string.format("+%d°c", wgt.values.EscT_max)

    wgt.values.EscT_percent = math.min(100, math.floor(100 * (wgt.values.EscT / tempTop)))
    wgt.values.EscT_max_percent = math.min(100, math.floor(100 * (wgt.values.EscT_max / tempTop)))
end

local function updateELRS(wgt)
    wgt.values.rqly = getValue("RQly")
    if (wgt.values.rqly <= 0) then
        wgt.values.rqly = getValue("VFR")
    end
    local rqly_min = getValue("RQly-")
    if (rqly_min <= 0) then
        rqly_min = getValue("VFR-")
    end

    if rqly_min > 0 then
        wgt.values.rqly_min = rqly_min
    end
    wgt.values.rqly_str = string.format("%d%%", wgt.values.rqly)
    wgt.values.rqly_min_str = string.format("%d%%", wgt.values.rqly_min)
end

local function playSoundFile(soundFile)
    if (wgt.is_connected == false or wgt.options.enableAudio == 0) then
        return
    end
    playFile(soundFile)
end

local function updateRateProfile(wgt)
    local val = getValue("RTE#")
    
    -- UI Update sofort
    wgt.values.rate_profile = val

    -- Initialisierung beim ersten Durchlauf (verhindert Sound beim Start)
    if wgt.values.rate_profile_announced == -1 then
        wgt.values.rate_profile_announced = val
        wgt.values.rate_profile_pending = val
        return
    end

    if val ~= wgt.values.rate_profile_pending then
        wgt.values.rate_profile_pending = val
        wgt.values.rate_profile_switch_time = clock() + 0.5 -- 0.5s Delay
    end

    if clock() > wgt.values.rate_profile_switch_time and wgt.values.rate_profile_announced ~= wgt.values.rate_profile_pending then
        wgt.values.rate_profile_announced = wgt.values.rate_profile_pending
        local soundFile = "fm-"..wgt.values.rate_profile_announced..".wav"
        if wgt.values.rate_profile_announced == wgt.options.auroprofile then
            soundFile = "auro.wav"
        end
        playSoundFile(soundFile)
    end
end

local function updatPidProfile(wgt)
    wgt.values.pid_profile = getValue("PID#")
end

local function updateRescue(wgt)
    local val = getValue("Resc")
    local is_rescue = (val > 0)

    if wgt.values.rescue_on ~= is_rescue then
        wgt.values.rescue_on = is_rescue
        if is_rescue then
            playSoundFile("rescue.wav")
        end
    end
end

local function playCraftName(wgt)
    local modelName = wgt.values.craft_name
    if (modelName == wgt.values.sound_file) then
        return
    end
    local soundFile = "/SOUNDS/RF2/"..modelName..".wav"
    playSoundFile(soundFile)
    if modelName ~= wgt.values.sound_file then
        wgt.values.sound_file = modelName
        -- log("playCraftName - model changed, %s --> %s", wgt.values.sound_file, modelName)
    end
end



local function updateImage(wgt)
    local newCraftName = wgt.values.craft_name
    if newCraftName == wgt.values.img_craft_name_for_image then
        return
    end
    local filename = "/IMAGES/"..newCraftName..".png"
    if isFileExist(filename) == false then
        filename = "/IMAGES/".. model.getInfo().bitmap
        if model.getInfo().bitmap == "" or isFileExist(filename) == false then
            filename = baseDir.."/widgets/img/rf2_logo.png"
        end
    end

    if newCraftName ~= wgt.values.img_craft_name_for_image then
        wgt.values.img_last_name = filename
        wgt.values.img_craft_name_for_image = newCraftName
    end
end

local function updateOnNoConnection(wgt)
    wgt.values.arm_disable_flags_txt = ""
    wgt.values.arm_fail = false
    wgt.values.craft_name = "-------"
    wgt.not_connected_error = "Not connected"
    wgt.isInitialized = false
    wgt.is_arm = false
    wgt.is_telem = false
    wgt.is_connected = false
    collectgarbage()
end

---------------------------------------------------------------------------------------



local function update(wgt, options)
    log("update")
    if (wgt == nil) then return end
    wgt.options = options
    wgt.not_connected_error = "Not connected"

<<<<<<< Updated upstream
=======
    -- Load custom settings from file and merge with defaults
    local settingsLib = assert(loadScript(baseDir .. "/lib/settings.lua"))()
    local savedSettings = settingsLib.load(SETTINGS_FILENAME)
    if savedSettings then
        log("Custom settings loaded from %s", SETTINGS_FILENAME)
        for key, value in pairs(savedSettings) do
            wgt.options[key] = value
        end
    else
        log("No custom settings file found. Using defaults.")
        -- Optionally, save the defaults immediately to create the file
        settingsLib.save(SETTINGS_FILENAME, wgt.options)
    end


    wgt.tools     = assert(loadScript(baseDir .. "/widgets/lib_widget_tools.lua", "btd"))(log, app_name)
    wgt.statusbar = assert(loadScript(baseDir .. "/widgets/parts/statusbar.lua",  "btd"))(log, app_name, wgt.tools)

>>>>>>> Stashed changes
    if (wgt.options.enableAudio == 1 or wgt.options.enableHaptic == 1) and wgt.task_capa_audio == nil then
        wgt.task_capa_audio = loadScript(baseDir .. "/tasks/task_capa_audio.lua", "btd")(log, app_name)
        wgt.task_capa_audio.init()
    end

    log("isFullscreen: %s", lvgl.isFullScreen())
    log("isAppMode: %s", lvgl.isAppMode())

    local dashboard_file_name = dashboard_styles[wgt.options.guiStyle] or dashboard_styles[1]
    if lvgl.isFullScreen() then
        dashboard_file_name = "rf2_dashboard_app_mode.lua"
    end
    log("update: gui style: %s", dashboard_file_name)
    build_ui(wgt, dashboard_file_name)
    return wgt
end

local function create(zone, options)
    wgt.zone = zone
    wgt.options = options
    return update(wgt, options)
end

<<<<<<< Updated upstream
=======
local function updateHspd(wgt)
    wgt.values.hspd = getValue("Hspd")
end


local function readBec(wgt)
   if (getValue("Vbec") == nil) then
        return
    end
    wgt.values.vbec = getValue("Vbec")
    if (wgt.values.vbec_min > wgt.values.vbec or wgt.values.vbec_min == 0) then
        wgt.values.vbec_min = wgt.values.vbec
    end
end

local function readTXPower(wgt)
    if (getValue("TPWR") == nil) then
        return
    end
    local value = getValue("TPWR")
    if (wgt.values.link_tx_power_max < value) then
        wgt.values.link_tx_power_max = value
    end
end

>>>>>>> Stashed changes
local function background(wgt)

    wgt.is_connected = wgt.is_connected

    updateCurr(wgt)
    updateCell(wgt)
    updateTimeCount(wgt)
    updateCraftName(wgt)
    updateCapa(wgt)
    updateThr(wgt)
    updateTemperature(wgt)
    updateImage(wgt)
    playCraftName(wgt)
    updateELRS(wgt)
    updateRateProfile(wgt)
    updatPidProfile(wgt)
    updateRescue(wgt)
    updateARM(wgt)
    updateARMD(wgt)
    updateFlyStat(wgt)

<<<<<<< Updated upstream
    if wgt.task_capa_audio then
        wgt.task_capa_audio.run(wgt)
    end
    
=======
    if getRSSI() > 0 then
        readTXPower(wgt)
        readBec(wgt)
        updateELRS(wgt)
        updateHspd(wgt)
>>>>>>> Stashed changes

    -- not on air, msp allowed

    if getRSSI() > 0 then
        lastTime = clock()
        wgt.is_connected = true
    elseif getRSSI() == 0 then
        if lastTime and clock() - lastTime < 5 then
            -- Do not re-initialise if the RSSI is 0 for less than 5 seconds.
            -- This is also a work-around for https://github.com/ExpressLRS/ExpressLRS/issues/3207 (AUX channel bug in ELRS TX < 3.5.5)
            return
        end
        if wgt.is_connected then
            -- state = STATE.WAIT_FOR_CONNECTION_INIT
            updateOnNoConnection(wgt)
            -- return
        end
    end

    -- Save settings if they are marked as dirty and enough time has passed
    local now = clock()
    if wgt.isDirty and (now - wgt.lastSaveTime > 5) then -- Save every 5 seconds if dirty
        local settingsLib = assert(loadScript(baseDir .. "/lib/settings.lua"))()
        local success = settingsLib.save(SETTINGS_FILENAME, wgt.options)
        if success then
            log("Settings saved automatically.")
            wgt.isDirty = false
            wgt.lastSaveTime = now
        else
            log("Error: Failed to save settings.")
        end
    end
end

local function refresh(wgt, event, touchState)
    if (wgt == nil) then return end

    -- log("refresh: event=%s", tostring(event))
    background(wgt)
    -- log("refresh: after background")

    dbgLayout()
    -- log("refresh: done")
end

return {create=create, update=update, background=background, refresh=refresh}
