local shell = require("shell")
local filesystem = require("filesystem")
local brent = {}

function brent.install(package)
  if filesystem.exists("/lib/" .. package .. ".lua") then
    filesystem.remove("/lib/" .. package .. ".lua")
  end
  shell.execute("wget https://raw.githubusercontent.com/Asteroid4/OpenComputersPackages/refs/heads/main/" .. package .. ".lua /lib/" .. package .. ".lua")
  print("Installed " .. package .. "successfully!")
end

function brent.uninstall(package)
  if filesystem.exists("/lib/" .. package .. ".lua") then
    filesystem.remove("/lib/" .. package .. ".lua")
    print("Uninstalled " .. package .. " successfully!")
  else
    print("That package is not installed!")
  end
end

return brent
