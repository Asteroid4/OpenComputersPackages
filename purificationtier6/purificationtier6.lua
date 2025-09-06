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
  transposer.transferItem(config.transposer_lens_side, config.transposer_chest_side, 1, 1, current_lens)
  local items_transferred = transposer.transferItem(config.transposer_chest_side, config.transposer_lens_side, 1, next_lens, 1)
  io.write(string.format("Switched from lens %d to lens %d.\n", current_lens, next_lens))
  return items_transferred == 1
end

function main(config)
  if version > config.version then
    io.write(string.format("The program is using version %d, which is newer than the config file's version, %d.\n", version, config.version))
  elseif version < config.version then
    io.write(string.format("The program is using version %d, which is older than the config file's version, %d.\n", version, config.version))
  end
  local current_lens = 1
  local last_swap_signal = 0
  local last_restart_signal = 15
  local sane = true
  while sane do
    if redstone.getInput(config.recipe_restart_side) == 0 and last_restart_signal ~= 0 then
      sane = switch_lens(config, current_lens, 1)
      current_lens = 1
      io.write("Restarting recipe...\n")
    elseif redstone.getInput(config.lens_swap_side) ~= 0 and last_swap_signal == 0 then
      local next_lens = current_lens + 1
      if next_lens == 10 then
        next_lens = 1
      end
      sane = switch_lens(config, current_lens, next_lens)
      current_lens = next_lens
      io.write("Switching to next lens...\n")
    end
  end
  io.write("An error has occurred, exiting...")
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
