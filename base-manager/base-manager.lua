local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone

local version = 1
local config_path = "/etc/base-manager.cfg"
local default_config_path = "/etc/base-manager.cfg.d"

function main(config)
  if version > config.version then
    io.write(string.format("[WARN] The program is using version %d, which is newer than the config file's version, %d.\n", version, config.version))
  elseif version < config.version then
    io.write(string.format("[WARN] The program is using version %d, which is older than the config file's version, %d.\n", version, config.version))
  end
  error = false
  if not component.isAvailable("redstone") then
    io.stderr:write("[ERROR] Unable to find redstone card.\n")
    error = true
  else
    io.write("[INFO] Found redstone card!\n")
  end
  if error then
    os.exit()
  end
  redstone = component.redstone
  io.stderr:write("[ERROR] Unknown error detected! Shutting down...")
end

function load_config()
  local file = io.open(config_path)
  local config = serial.unserialize(file:read("*a"))
  io.write("Config loaded successfully!\n")
  main(config)
end

io.write("[INFO] Searching for config file...\n")
if fs.exists(config_path) then
  io.write("[INFO] Config found. Loading config... ")
  load_config()
else
  io.write("[INFO] No config exists, searching for default... ")
  if fs.exists(default_config_path) then
    io.write("Default config found.\n")
    if fs.copy(default_config_path,  config_path) then
      io.write("[INFO] Created config using default. Loading config... ")
      load_config()
    else
      io.write("[ERROR] Copy failed. Exiting...\n")
    end
  else
      io.write("\n[ERROR] No default config found. Exiting...\n")
  end
end
