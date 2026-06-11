local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone
local transposer
local bhc

local version = 1
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
  if not component.isAvailable("gt_machine") then
    io.stderr:write("[ERROR] Unable to find BHC controller. Exiting...\n")
    os.exit()
  else
    io.write("[INFO] Found BHC controller!\n")
    bhc = component.gt_machine
  end
  local sane = true
  local internal_black_hole_active = false
  local timer = 0
  while sane do
    if redstone.getInput(config.black_hole_active_side_input) == 0 then
      if redstone.getInput(config.recipes_ready_side_input) > 0 and not internal_black_hole_active then
        transposer.transferItem(config.black_hole_seed_side_on_transposer, config.input_side_on_transposer, 1, 2, 1)
        redstone.setOutput(config.recipes_inputs_side_output, 15)
        internal_black_hole_active = true
        timer = 2000
        io.write("[INFO] Black Hole opening...\n")
      end
    else
      if redstone.getOutput(config.spacetime_inputs_side_output) == 0 then
        timer = timer - 1
        if timer % 100 == 0 then
          io.write(string.format("[INFO] Black Hole time remaining: %d seconds.\n", timer // 20))
        end
      end
      if timer < 200 then
        redstone.setOutput(config.recipes_inputs_side_output, 0)
        if bhc.getWorkMaxProgress() - bhc.getWorkProgress() > timer - 100 then
          redstone.setOutput(config.spacetime_inputs_side_output, 15)
          io.write("[INFO] Inputting Spacetime to halt decay...\n")
        end
        if bhc.getWorkMaxProgress() == 0 then
          transposer.transferItem(config.black_hole_collapser_side_on_transposer, config.input_side_on_transposer, 1, 2, 1)
          internal_black_hole_active = false
          redstone.setOutput(config.spacetime_inputs_side_output, 0)
          io.write("[INFO] Black Hole closing...\n")
        end
      end
    end
    os.sleep(0.05)
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
