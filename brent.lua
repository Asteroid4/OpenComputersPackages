local shell = require("shell")
local filesystem = require("filesystem")
local computer = require("computer")
local internet = require("internet")
local brent = {}

function brent.list()
  result = ""
  for chunk in internet.request("https://raw.githubusercontent.com/Asteroid4/OpenComputersPackages/refs/heads/main/list")
  do result = result..chunk end
  print(result)
end

function brent.install(package, prompt)
  if filesystem.exists("/lib/" .. package .. ".lua") then
    filesystem.remove("/lib/" .. package .. ".lua")
    print("That package is already installed!")
  else
    shell.execute("wget https://raw.githubusercontent.com/Asteroid4/OpenComputersPackages/refs/heads/main/" .. package .. ".lua /lib/" .. package .. ".lua")
    print("Installed " .. package .. " successfully!")
    if prompt then
      io.write("Reboot? (Y/n) ")
      if io.read() == "Y" then
        computer.shutdown(true)
      end
    end
  end
end

function brent.uninstall(package, prompt)
  if filesystem.exists("/lib/" .. package .. ".lua") then
    filesystem.remove("/lib/" .. package .. ".lua")
    print("Uninstalled " .. package .. " successfully!")
    if prompt then
      io.write("Reboot? (Y/n) ")
      if io.read() == "Y" then
        computer.shutdown(true)
      end
    end
  else
    print("That package is not installed!")
  end
end

function brent.update(package)
  brent.uninstall(package)
  brent.install(package)
end

return brent
