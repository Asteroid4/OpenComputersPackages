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
  local generator_enabled = true
  local low_machines_enabled = true
  local high_machines_enabled = true
  while true do
    local bundled_input = redstone.getBundledInput(config.bundled_input_side)
    if redstone.getInput(config.manual_override_side) > 0 then
      redstone.setBundledOutput(config.bundled_output_side, bundled_input)
      redstone.setOutput(config.alarm_output_side, 0)
    else
      local power_remaining = redstone.getInput(config.power_remaining_side)
      if power_remaining >= config.generator_deactivate_threshold then
        generator_enabled = false
        redstone.setOutput(config.alarm_output_side, 0)
        low_machines_enabled = true
        high_machines_enabled = true
      elseif power_remaining > config.generator_activate_threshold then
        redstone.setOutput(config.alarm_output_side, 0)
        low_machines_enabled = true
        high_machines_enabled = true
      else
        generator_enabled = true
        if power_remaining <= config.low_threshold then
          low_machines_enabled = false
          if power_remaining <= config.high_threshold then
            redstone.setOutput(config.alarm_output_side, 15)
            high_machines_enabled = false
          else
            redstone.setOutput(config.alarm_output_side, 0)
            high_machines_enabled = true
          end
        else
          redstone.setOutput(config.alarm_side, 0)
          low_machines_enabled = true
          high_machines_enabled = true
        end
      end
      bundled_output = bundled_input
      if generator_enabled then
        bundled_output[config.generator_color] = 255
      end
      if low_machines_enabled then
        for _, machine_color in ipairs(config.low_priority_machines) do
          bundled_output[machine_color] = 255
        end
      end
      if high_machines_enabled then
        for _, machine_color in ipairs(config.high_priority_machines) do
          bundled_output[machine_color] = 255
        end
      end
      redstone.setBundledOutput(config.bundled_output_side, bundled_output)
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
