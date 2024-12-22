local shell = require("shell")
local filesystem = require("filesystem")
local brent = {}

function brent.install(package)
  if filesystem.exists("/libs/" .. package .. ".lua") then
    filesystem.remove("/libs/" .. package .. ".lua")
  end
  shell.execute("wget https://raw.githubusercontent.com/Asteroid/OpenComputersPackages/refs/heads/main/" .. package .. ".lua /libs/" .. package .. ".lua")
end
