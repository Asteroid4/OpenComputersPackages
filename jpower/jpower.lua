local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone

local config_path = "/etc/jpower.cfg"
local default_config_path = "/etc/jpower.cfg.d"

if component.isAvailable("redstone") then
  redstone = component.redstone
else
  io.stderr:write("A tier 2 redstone card is required.")
  os.exit()
end

function main(config)
  while true do
    local bundled_input = redstone.getBundledInput(config.bundled_input_side)
    if redstone.getInput(config.manual_override_side) > 0 then
      redstone.setBundledOutput(config.bundled_output_side, redstone.getBundledInput(config.bundled_input_side))
    else
      local power_remaining = redstone.getInput(config.power_remaining_side)
      local new_bundled_output = redstone.getBundledOutput(config.bundled_output_side)
      local old_bundled_output = redstone.getBundledOutput(config.bundled_output_side)
      if old_bundled_output[config.generator_color] > 0 then
        if power_remaining >= config.generator_deactivate_threshold then
          new_bundled_output[config.generator_color] = 0
        end
      else
        if power_remaining <= config.generator_activate_threshold then
          new_bundled_output[config.generator_color] = 255
        end
      end
      if power_remaining <= config.alarm_threshold then
        new_bundled_output[config.alarm] = 255
      else
        new_bundled_output[config.alarm] = 0
      end
      redstone.setBundledOutput(config.bundled_output_side, new_bundled_output)
    end
    os.sleep(1)
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
