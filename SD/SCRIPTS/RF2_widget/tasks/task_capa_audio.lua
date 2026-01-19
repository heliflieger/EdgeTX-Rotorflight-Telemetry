local arg = {...}
local log = arg[1]
local app_name = arg[2]

local M = {}

local last_capa_perc_parted = nil
local last_capa_anounce = 0

local function m_clock()
    return getTime() / 100
end

M.init = function(wgt)
    last_capa_perc_parted = 100
end

local function playCapacityValue_by_percent(wgt)
    if wgt.options.enableAudio == 0 or getRSSI() == 0 or wgt.values.is_arm == false then
        return
    end

    log("playCapacityValue: %s", wgt.values.capaPercent)
    playFile("battry.wav")
    playNumber(wgt.values.capaPercent, UNIT_PERCENT, 0)
end

-- play capacity audio when capacity percent drops to 50%, 30%
-- play capacity audio when capacity percent is below 20% every 10 seconds
-- play capacity audio when capacity percent is below 30% every 20 seconds
M.run = function(wgt)
    local new_capa = wgt.values.capaPercent
    local new_capa_parted = math.ceil(new_capa / 10) * 10
    -- log("audio for capacity: last=%s new=%s", last_capa_perc_parted, new_capa_parted)
    if new_capa_parted ~= last_capa_perc_parted then
        local is_drop = new_capa_parted < last_capa_perc_parted
        last_capa_perc_parted = new_capa_parted
        if is_drop then
            log("audio for capacity - new capacity: %s", new_capa)
            if new_capa_parted == 50 or new_capa_parted == 30 or wgt.options.every10percent then
                playCapacityValue_by_percent(wgt)
                return 1
            end
        else
            return 0
        end
    end


    if new_capa_parted < 20 then
        if m_clock() - last_capa_anounce > 10 then
            log("task_capa_audio: time to play critical capacity")
            playCapacityValue_by_percent(wgt)
            if wgt.options.enableHaptic == 1 and getRSSI() > 0 and wgt.values.is_arm then
                playHaptic(25, 0, 0)
            end
            last_capa_anounce = m_clock()
        end
    elseif new_capa_parted < 30 then
        if m_clock() - last_capa_anounce > 20 then
            log("task_capa_audio: time to play low capacity")
            playCapacityValue_by_percent(wgt)
            if wgt.options.enableHaptic == 1 and getRSSI() > 0 and wgt.values.is_arm then
                playHaptic(15, 0, 0)
            end
            last_capa_anounce = m_clock()
        end
    end

    return 0
end


return M
