local M = {}
local app_name = "RF2_widget" -- Default name

function M.init(name)
    if name then
        app_name = name
    end
end

function M.log(fmt, ...)
    print(string.format("[%s] " .. fmt, app_name, ...))
end

return M