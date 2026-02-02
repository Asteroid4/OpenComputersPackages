local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone
local transposer_quark_in
local transposer_quark_out
local transposer_fluid_out

local version = 2
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
  local quarks_to_craft = {0,0,0,0,0,0}
  local quark_index = 1
  local quark_pair_found = false
  local sane = true
  while sane do
    if redstone.getInput(config.machine_active_signal_computer_side) > 0 then
      if not quark_pair_found then
        if transposer_quark_in.getSlotStackSize(config.input_side_on_quark_in, 1) == 0 then
          if transposer_fluid_out.getTankLevel(config.fluid_in_side_on_fluid_out, 1) == 2000 then
            transposer_fluid_out.transferFluid(config.fluid_in_side_on_fluid_out, config.fluid_out_side_on_fluid_out, 2000)
            quark_pair_found = true
            io.write(string.format("[INFO] Quark pair found to be quarks %s and %s!\n", quark_sequence[quark_index - 1], quark_sequence[quark_index - 2]))
            quarks_to_craft[quark_sequence[quark_index - 1]] = quarks_to_craft[quark_sequence[quark_index - 1]] + 1
            quarks_to_craft[quark_sequence[quark_index - 2]] = quarks_to_craft[quark_sequence[quark_index - 2]] + 1
          else
            transposer_quark_in.transferItem(config.chest_side_on_quark_in, config.input_side_on_quark_in, 1, quark_sequence[quark_index], 1)
            io.write(string.format("[INFO] Inserted quark %s.\n", quark_sequence[quark_index]))
            quark_index = quark_index + 1
          end
        end
      end
    end
    if transposer_quark_out.getSlotStackSize(config.chest_side_on_quark_out, 7) > 0 then
      if quark_pair_found then
        io.write("[INFO] Restarting recipe...\n")
        transposer_fluid_out.transferFluid(config.fluid_in_side_on_fluid_out, config.fluid_out_side_on_fluid_out, transposer_fluid_out.getTankLevel(config.fluid_in_side_on_fluid_out, 1))
        transposer_quark_in.transferItem(config.input_side_on_quark_in, config.chest_side_on_quark_in, 1, 1)
        quark_pair_found = false
        quark_index = 1
      end
      if quarks_to_craft[1] > 0 then
        io.write("[INFO] Realigning quark 1...\n")
        transposer_quark_in.transferItem(config.chest_side_on_quark_in, config.up_quark_realignment_side_on_quark_in, 1, 7, 1)
        quarks_to_craft[1] = quarks_to_craft[1] - 1
      elseif quarks_to_craft[2] > 0 then
        io.write("[INFO] Realigning quark 2...\n")
        transposer_quark_in.transferItem(config.chest_side_on_quark_in, config.down_quark_realignment_side_on_quark_in, 1, 7, 1)
        quarks_to_craft[2] = quarks_to_craft[2] - 1
      elseif quarks_to_craft[3] > 0 then
        io.write("[INFO] Realigning quark 3...\n")
        transposer_quark_in.transferItem(config.chest_side_on_quark_in, config.bottom_quark_realignment_side_on_quark_in, 1, 7, 1)
        quarks_to_craft[3] = quarks_to_craft[3] - 1
      elseif quarks_to_craft[4] > 0 then
        io.write("[INFO] Realigning quark 4...\n")
        transposer_quark_out.transferItem(config.chest_side_on_quark_out, config.top_quark_realignment_side_on_quark_out, 1, 7, 1)
        quarks_to_craft[4] = quarks_to_craft[4] - 1
      elseif quarks_to_craft[5] > 0 then
        io.write("[INFO] Realigning quark 5...\n")
        transposer_quark_out.transferItem(config.chest_side_on_quark_out, config.strange_quark_realignment_side_on_quark_out, 1, 7, 1)
        quarks_to_craft[5] = quarks_to_craft[5] - 1
      elseif quarks_to_craft[6] > 0 then
        io.write("[INFO] Realigning quark 6...\n")
        transposer_quark_out.transferItem(config.chest_side_on_quark_out, config.charm_quark_realignment_side_on_quark_out, 1, 7, 1)
        quarks_to_craft[6] = quarks_to_craft[6] - 1
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
