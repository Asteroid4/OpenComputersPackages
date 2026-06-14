local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local computer = require("computer")
local redstone
local transposer

local version = 2
local config_path = "/etc/bhc-controller.cfg"
local default_config_path = "/etc/bhc-controller.cfg.d"

function main(config)
  if version > config.version then
    io.write(string.format("[WARN] The program is using version %d, which is newer than the config file's version, %d.\n", version, config.version))
  elseif version < config.version then
    io.write(string.format("[WARN] The program is using version %d, which is older than the config file's version, %d.\n", version, config.version))
  end
  if not component.isAvailable("redstone") then
    io.stderr:write("[ERROR] Unable to find redstone card. Exiting...\n")
    os.exit()
  else
    io.write("[INFO] Found redstone card!\n")
    redstone = component.redstone
  end
  if not component.isAvailable("transposer") then
    io.stderr:write("[ERROR] Unable to find transposer. Exiting...\n")
    os.exit()
  else
    io.write("[INFO] Found transposer!\n")
    transposer = component.transposer
  end
  local sane = true
  local activating = false
  local closing = false
  local black_hole_uptime = 0
  local spacetime_uptime = 0
  local last_recorded_time = 0
  while sane do
    if redstone.getInput(config.black_hole_active_side_input) == 0 then
      if closing then
        io.write("[INFO] Black Hole closed.\n")
      end
      redstone.setOutput(config.spacetime_inputs_side_output, 0)
      closing = false
      black_hole_uptime = 0
      spacetime_uptime = 0
      if redstone.getInput(config.recipes_ready_side_input) > 0 and not activating then
        io.write("[INFO] Black Hole opening...\n")
        transposer.transferItem(config.black_hole_seed_side_on_transposer, config.input_side_on_transposer, 1, 2, 1)
        activating = true
      end
    else
      if activating then
        io.write("[INFO] Black Hole opened.\n")
      end
      activating = false
      if redstone.getOutput(config.spacetime_inputs_side_output) > 0 then
        spacetime_uptime = spacetime_uptime + last_recorded_time - computer.uptime()
      else
        black_hole_uptime = black_hole_uptime + last_recorded_time - computer.uptime()
      end
      if black_hole_uptime > 90 then
        io.write("[INFO] Inserting Spacetime to halt decay...\n")
        redstone.setOutput(config.spacetime_inputs_side_output, 15)
        if spacetime_uptime > config.min_spacetime_time or redstone.getInput(config.recipes_ready_side_input) == 0 then
          if not closing then
            io.write("[INFO] Black Hole closing...\n")
            transposer.transferItem(config.black_hole_seed_side_on_transposer, config.input_side_on_transposer, 1, 2, 1)
            closing = true
          end
        end
      end
    end
    io.write(spacetime_uptime)
    io.write(" then ")
    io.write(black_hole_uptime)
    io.write("\n")
    last_recorded_time = computer.uptime()
    os.sleep(1)
  end
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
