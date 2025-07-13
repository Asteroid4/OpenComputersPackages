config_path = "/etc/jconftest.cfg"
default_config_path = "/etc/jconftest.cfg.d"
io.write("Searching for config file...")
if filesystem.exists(config_path) then
  io.write("Config exists, test complete!")
else
  io.write("No config exists, searching for default...")
  if filesystem.exists(default_config_path) then
    io.write("Default found!")
    if filesystem.copy(default_config_path,  config_path) then
      io.write("Copied default to config. Test complete!")
    else
      io.write("Copy failed, test failed.")
    end
  else
      io.write("No default found! Test failed.")
  end
end
