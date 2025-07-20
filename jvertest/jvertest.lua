local fs = require("filesystem")
local serial = require("serialization")

local version = 1
local config_path = "/etc/jvertest.cfg"
local default_config_path = "/etc/jvertest.cfg.d"

function main(config)
  if version > config.version then
    io.write(string.format("The program is using version %d, which is newer than the config file's version, &d.", version, config.version))
  elseif version < config.version then
    io.write(string.format("The program is using version %d, which is older than the config file's version, &d.", version, config.version))
  else
    io.write(string.format("The program is using version %d, which is the same as the config file's version.", version))
  end
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
