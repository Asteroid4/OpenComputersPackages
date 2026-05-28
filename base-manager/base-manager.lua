local fs = require("filesystem")
local serial = require("serialization")
local component = require("component")
local redstone

local version = 1
local config_path = "/etc/base-manager.cfg"
local default_config_path = "/etc/base-manager.cfg.d"

function main(config)
  if version > config.version then
    io.write(string.format("[WARN] The program is using version %d, which is newer than the config file's version, %d.\n", version, config.version))
  elseif version < config.version then
    io.write(string.format("[WARN] The program is using version %d, which is older than the config file's version, %d.\n", version, config.version))
  end
  components = {}
  for addr, salted_name in pairs(config.monitored_components) do
    local address = component.get(addr)
    if type(address) ~= "string" then
      io.write(string.format("[WARN] Invalid component address recieved, %s does not represent a valid component. Skipping...\n", addr))
    else
      local component = component.proxy(address)
      component["base_manager_name"] = string.sub(salted_name, 1, -2)
      local postfix = string.sub(salted_name, -1, -1)
      if postfix == "!" then
        component["is_critical"] = true
        table.insert(components, component)
      else
        if postfix == "." then
          component["is_critical"] = false
          table.insert(components, component)
        else
          io.write(string.format("[WARN] Component \"%s\" (%s) does not end in either \'!\' or \'.\', skipping...\n", string.sub(salted_name, 1, -2), address))
        end
      end
    end
  end
  if (#components == 0) then
    io.write("[ERROR] No components available to monitor! Exiting...")
    os.exit()
  end
  io.write("[INFO] Starting monitor...\n")
  os.sleep(10)
  local sane = true
  while sane do
    for _, component in pairs(components) do
      io.write(component.base_manager_name)
      io.write(component.is_critical)
      io.write("")
    end
    sane = false
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
