local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone
local transposer

local version = 1
local config_path = "/etc/purificationtier6.cfg"
local default_config_path = "/etc/purificationtier6.cfg.d"

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

local function switch_lens(config, current_lens, next_lens)
  local items_transferred = transposer.transferItem(config.transposer_lens_side, config.transposer_chest_side, 1, 1, current_lens)
  if items_transferred != 1 then
    return false
  end
  items_transferred = transposer.transferItem(config.transposer_chest_side, config.transposer_lens_side, 1, next_lens, 1)
  return items_transferred == 1
end

function main(config)
  if version > config.version then
    io.write(string.format("The program is using version %d, which is newer than the config file's version, %d.\n", version, config.version))
  elseif version < config.version then
    io.write(string.format("The program is using version %d, which is older than the config file's version, %d.\n", version, config.version))
  end
  local current_lens = 1
  local sane = true
  while sane do
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
