local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone
local transposer

local version = 1
local config_path = "/etc/purificationtier8.cfg"
local default_config_path = "/etc/purificationtier8.cfg.d"

if component.isAvailable("redstone") then
  redstone = component.redstone
else
  io.stderr:write("A tier 2 redstone card is required.")
  os.exit()
end

if component.isAvailable("transposer") then
  transposer = component.transposer
else
  io.stderr:write("A transposer is required.")
  os.exit()
end

function main(config)
  if version > config.version then
    io.write(string.format("The program is using version %d, which is newer than the config file's version, %d.\n", version, config.version))
  elseif version < config.version then
    io.write(string.format("The program is using version %d, which is older than the config file's version, %d.\n", version, config.version))
  end
  local quark_sequence = {1,2,3,4,5,6, 1,3,5,2,6,4, 1,5,2,4,3,6}
  local last_quark = 0
  local second_to_last_quark = 0
  local error = false
end

function load_config()
  local file = io.open(config_path)
  local config = serial.unserialize(file:read("*a"))
  io.write("Config loaded successfully!\n")
  main(config)
end

io.write("Searching for config file...\n")
if fs.exists(config_path) then
  io.write("Config found. Loading config... ")
  load_config()
else
  io.write("No config exists, searching for default... ")
  if fs.exists(default_config_path) then
    io.write("Default config found.\n")
    if fs.copy(default_config_path,  config_path) then
      io.write("Created config using default. Loading config... ")
      load_config()
    else
      io.write("Copy failed. Exiting...\n")
    end
  else
      io.write("\nNo default config found. Exiting...\n")
  end
end
