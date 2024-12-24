local shell = require("shell")
local filesystem = require("filesystem")
local computer = require("computer")
local internet = require("internet")
local args, options = shell.parse(...)

function install(package, noprompt)
  if filesystem.exists("/lib/" .. package .. ".lua") then
    print("That package is already installed!")
  else
    shell.execute("wget https://raw.githubusercontent.com/Asteroid4/OpenComputersPackages/refs/heads/main/" .. package .. ".lua /lib/" .. package .. ".lua")
    print("Installed " .. package .. " successfully!")
    if not noprompt then
      io.write("Reboot? (Y/n) ")
      if io.read() == "Y" then
        computer.shutdown(true)
      end
    end
  end
end

function uninstall(package, noprompt)
  if filesystem.exists("/lib/" .. package .. ".lua") then
    filesystem.remove("/lib/" .. package .. ".lua")
    print("Uninstalled " .. package .. " successfully!")
    if not noprompt then
      io.write("Reboot? (Y/n) ")
      if io.read() == "Y" then
        computer.shutdown(true)
      end
    end
  else
    print("That package is not installed!")
  end
end

function help()
  print([[Usage:
  brent list
  brent install <package>
  brent uninstall <package>
  brent update <package>]])
end

if options.h then
  help()
elseif args[0] == "list" then
  result = ""
  for chunk in internet.request("https://raw.githubusercontent.com/Asteroid4/OpenComputersPackages/refs/heads/main/list")
  do result = result..chunk end
  print(result)
elseif args[0] == "install" then
  install(false)
elseif args[0] == "uninstall" then
  uninstall(false)
elseif args[0] == "update" then
  brent.uninstall(package, true)
  brent.install(package, false)
else
  help()
end