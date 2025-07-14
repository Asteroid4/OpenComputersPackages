local fs = require("filesystem")
local serial = require("serialization")

local config = {}
local config_path = "/etc/jconftest.cfg"
local default_config_path = "/etc/jconftest.cfg.d"

function main()
  io.write(string.format("foo is %d and bar is %d", config.foo, config.bar))
end

function load_config()
  file = io.open(config_path)
  config = serial.unserialize(file.read("*a"))
  io.write("Config loaded successfully!\n")
  main()
end

io.write("Searching for config file...\n")
if fs.exists(config_path) then
  io.write("Config found. Loading config...\n")
  load_config()
else
  io.write("No config exists, searching for default...\n")
  if fs.exists(default_config_path) then
    io.write("Default config found.\n")
    if fs.copy(default_config_path,  config_path) then
      io.write("Created config using default. Loading config...\n")
      load_config()
    else
      io.write("Copy failed. Exiting...\n")
    end
  else
      io.write("No default config found. Exiting...\n")
  end
end
