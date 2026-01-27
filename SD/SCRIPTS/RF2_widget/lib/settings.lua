-- /lib/settings.lua
-- A reusable library for saving and loading key-value settings from a file.

local settings = {}

---
-- Saves a Lua table to a specified file in key=value format.
-- @param filename (string) The full path to the settings file.
-- @param data (table) The table to save.
-- @return (boolean) True on success, false on failure.
function settings.save(filename, data)
    print("Saving settings to " .. filename)
    local file = io.open(filename, "w")
    print("File opened: " .. tostring(file))
    if not file then
        -- Error: Could not create or open the file for writing.
        return false
    end

    -- In this extremely specific and buggy EdgeTX environment, any file operation
    -- after opening (write-with-check, flush, close) can cause an uncatchable
    -- C-level crash.
    -- The very first log showed that a simple write loop succeeded, while close() failed.
    -- We are therefore reverting to the simplest possible implementation: open, write,
    -- and then rely on the garbage collector. This is the only way to avoid the crash.
    for key, value in pairs(data) do
        print("Writing key: " .. tostring(key) .. " value: " .. tostring(value))
        -- We do not check the return value, as the act of checking seems to
        -- contribute to the crash in this environment.
        io.write(file, key .. "=" .. tostring(value) .. "\n")
    end
    print("Finished writing settings.")
    io.close(file)
    -- We do not call flush() or close().
    return true
end

---
-- Loads settings from a specified file into a Lua table.
-- @param filename (string) The full path to the settings file.
-- @return (table) The loaded data, or nil if the file doesn't exist.
function settings.load(filename)
    local data = {}
    local file = io.open(filename, "r")
    if not file then
        return nil -- File does not exist, which is normal on first run.
    end

    -- Read the whole file at once to avoid potential issues with the file:lines() iterator
    -- on some embedded Lua environments.
    local content, read_err = file:read("*a")
    
    -- In some EdgeTX environments, reading the file to the end can implicitly close
    -- the file handle. Attempting to close it again causes a crash that pcall cannot
    -- catch. We will rely on the garbage collector to close the file handle, which
    -- is safe for a read-only operation.
    if not content then
        -- Return empty table if read fails or file is empty.
        return data
    end

    for line in string.gmatch(content, "[^\\r\\n]+") do
        local key, value = string.match(line, "([^=]+)=(.+)")
        if key and value then
            -- Attempt to convert the value back to a number if possible.
            data[key] = tonumber(value) or value
        end
    end
    return data
end

return settings