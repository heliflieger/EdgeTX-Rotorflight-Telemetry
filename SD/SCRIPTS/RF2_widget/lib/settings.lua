-- /lib/settings.lua
-- A reusable library for saving and loading key-value settings from a file.

local M = {}

---
-- Saves a Lua table to a specified file in key=value format.
-- @param filename (string) The full path to the settings file.
-- @param data (table) The table to save.
-- @return (boolean) True on success, false on failure.
function M.save(filename, data)
    local file = io.open(filename, "w")
    if not file then
        return false -- Error: Could not create or open the file for writing.
    end

    for key, value in pairs(data) do
        -- Write each entry as "key=value" followed by a newline.
        file:write(key .. "=" .. tostring(value) .. "\n")
    end

    file:close()
    return true
end

---
-- Loads settings from a specified file into a Lua table.
-- @param filename (string) The full path to the settings file.
-- @return (table) The loaded data, or nil if the file doesn't exist.
function M.load(filename)
    local data = {}
    local file = io.open(filename, "r")
    if not file then
        return nil -- File does not exist, which is normal on first run.
    end

    for line in file:lines() do
        local key, value = string.match(line, "([^=]+)=(.+)")
        if key and value then
            -- Attempt to convert the value back to a number if possible.
            data[key] = tonumber(value) or value
        end
    end

    file:close()
    return data
end

return M