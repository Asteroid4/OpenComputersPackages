config_path = "/etc/jconftest.cfg"
default_config_path = "/etc/jconftest.cfg.d"
io.write("Searching for config file...\n")
if filesystem.exists(config_path) then
  io.write("Config exists, test complete!\n")
else
  io.write("No config exists, searching for default...\n")
  if filesystem.exists(default_config_path) then
    io.write("Default found!\n")
    if filesystem.copy(default_config_path,  config_path) then
      io.write("Copied default to config. Test complete!\n")
    else
      io.write("Copy failed, test failed.\n")
    end
  else
      io.write("No default found! Test failed.\n")
  end
end
