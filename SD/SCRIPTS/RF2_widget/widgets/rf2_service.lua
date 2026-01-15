local baseDirRF2 = "/SCRIPTS/RF2/"

local backgroundTask
local reqTS = 0

rf2fc = {
    runningInSimulator = string.sub(select(2, getVersion()), -4) == "simu",
    msp = {
        ctl = {
            connected = false,
            -- mspGovernorConfig = false,
            lastServerTime = 0,
            lastUpdateTime = 0,
        },
    },
    clock = function()
        return getTime() / 100
    end,
    
}


local background = backgroundTask

return { run = background }
