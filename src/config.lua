local fs = require("filesystem")

local path = "/etc/ut3-gm.conf"

local function existsDir(path)
  return fs.exists(path) and fs.isDirectory(path)
end

local function existsFile(path)
  return fs.exists(path) and not fs.isDirectory(path)
end

local DEFAULT_CONFIG = [==[
network.port = 12345

-- Debug card addresses
network.addresses.control.red    = "12345678-1234-1234-1234-1234567890ab"
network.addresses.control.yellow = "12345678-1234-1234-1234-1234567890ab"
network.addresses.control.green  = "12345678-1234-1234-1234-1234567890ab"
network.addresses.control.blue   = "12345678-1234-1234-1234-1234567890ab"
network.addresses.glasses        = "12345678-1234-1234-1234-1234567890ab"
network.addresses.infopanels[1]  = "12345678-1234-1234-1234-1234567890ab"
network.addresses.infopanels[2]  = "12345678-1234-1234-1234-1234567890ab"
network.addresses.infopanels[3]  = "12345678-1234-1234-1234-1234567890ab"
network.addresses.infopanels[4]  = "12345678-1234-1234-1234-1234567890ab"
network.addresses.lamp           = "12345678-1234-1234-1234-1234567890ab"
network.addresses.radio          = "12345678-1234-1234-1234-1234567890ab"
]==]

local function loadConfig(contents)
  local base = {
    network = {
      addresses = {
        control = {},
        infopanels = {},
      }
    }
  }

  local default = {
    network = {
      addresses = {
        control = {
          red = "12345678-1234-1234-1234-1234567890ab",
          yellow = "12345678-1234-1234-1234-1234567890ab",
          green = "12345678-1234-1234-1234-1234567890ab",
          blue = "12345678-1234-1234-1234-1234567890ab"
        },
        infopanels = {
          [1] = "12345678-1234-1234-1234-1234567890ab",
          [2] = "12345678-1234-1234-1234-1234567890ab",
          [3] = "12345678-1234-1234-1234-1234567890ab",
          [4] = "12345678-1234-1234-1234-1234567890ab",
        },
        glasses = "12345678-1234-1234-1234-1234567890ab",
        lamp = "12345678-1234-1234-1234-1234567890ab",
        radio = "12345678-1234-1234-1234-1234567890ab",
      },
      port = 12345
    },
  }

  local config = {}

  local function deepCopy(value)
    if type(value) ~= "table" then
      return value
    end
    local result = {}
    for k, v in pairs(value) do
      result[k] = deepCopy(v)
    end
    return result
  end

  local function createEnv(base, default, config)
    return setmetatable({}, {
      __newindex = function(self, k, v)
        if base[k] then
          return nil
        end
        if default[k] then
          config[k] = v
        end
        return nil
      end,
      __index = function(self, k)
        if base[k] then
          config[k] = config[k] or {}
          return createEnv({}, default[k], config[k])
        end
        if default[k] then
          return config[k] or deepCopy(default[k])
        end
      end
    })
  end

  local env = createEnv(base, default, config)
  load(contents, "config", "t", env)()

  local function setGet(base, default, config)
    return setmetatable({}, {
      __index = function(self, k)
        if base[k] then
          config[k] = config[k] or {}
          return setGet(base[k], default[k], config[k])
        elseif config[k] then
          return config[k]
        elseif default[k] then
          return default[k]
        end
      end
    })
  end

  return setGet(base, default, config)
end

if not existsFile(path) then
  local dirPath = fs.path(path)
  if not existsDir(dirPath) then
    local result, reason = fs.makeDirectory(dirPath)
    if not result then
      error("failed to create '" .. tostring(dirPath) .. "' directory for the config file: " .. tostring(reason))
    end
  end
  local file, reason = io.open(path, "w")
  if file then
    file:write(DEFAULT_CONFIG)
    file:close()
  else
    error("failed to open config file for writing: " .. tostring(reason))
  end
end
local file, reason = io.open(path, "r")
if not file then
  error("failed to open config file for reading: " .. tostring(reason))
end
local content = file:read("*all")
file:close()

return loadConfig(content)
