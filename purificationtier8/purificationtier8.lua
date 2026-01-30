local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone
local transposer_quark_in
local transposer_quark_out
local transposer_fluid_out

local version = 1
local config_path = "/etc/purificationtier8.cfg"
local default_config_path = "/etc/purificationtier8.cfg.d"

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
  if component.get(config.transposer_quark_in_addr) == nil then
    io.stderr:write(string.format("[ERROR] Unable to find quark input transposer by address of %s.\n", config.transposer_quark_in_addr))
    error = true
  else
    io.write(string.format("[INFO] Found quark input transposer at address %s!\n", component.get(config.transposer_quark_in_addr)))
  end
  if component.get(config.transposer_quark_out_addr) == nil then
    io.stderr:write(string.format("[ERROR] Unable to find quark output transposer by address of %s.\n", config.transposer_quark_out_addr))
    error = true
  else
    io.write(string.format("[INFO] Found quark output transposer at address %s!\n", component.get(config.transposer_quark_out_addr)))
  end
  if component.get(config.transposer_fluid_out_addr) == nil then
    io.stderr:write(string.format("[ERROR] Unable to find fluid output transposer by address of %s.\n", config.transposer_fluid_out_addr))
    error = true
  else
    io.write(string.format("[INFO] Found fluid output transposer at address %s!\n", component.get(config.transposer_fluid_out_addr)))
  end
  if error then
    os.exit()
  end
  redstone = component.redstone
  transposer_quark_in = component.proxy(component.get(config.transposer_quark_in_addr))
  transposer_quark_out = component.proxy(component.get(config.transposer_quark_out_addr))
  transposer_fluid_out = component.proxy(component.get(config.transposer_fluid_out_addr))
  local quark_sequence = {1,2,3,4,5,6, 1,3,5,2,6,4, 1,5,2,4,3,6}
  local quark_index = 1
  local quark_pair_found = false
  local sane = true
  while sane do
    if redstone.getInput(config.machine_active_signal_computer_side) > 0 then
      if not quark_pair_found then
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
      io.write("Created config using default. Loading config... ")
      load_config()
    else
      io.write("[ERROR] Copy failed. Exiting...\n")
    end
  else
      io.write("\n[INFO] No default config found. Exiting...\n")
  end
end
