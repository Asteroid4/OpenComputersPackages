local component = require("component")
local event = require("event")
local sides = require("sides")
local os = require("os")
local alarm = {}

function activate()
    component.redstone.setOutput(sides.top, 15)
    os.sleep(alarmTime)
    component.redstone.setOutput(sides.top, 0)
end

function alarm.arm(alarmTime)
    component.modem.open(5042)
    event.listen("modem_message", activate)
end

function alarm.disarm()
    component.modem.close(5042)
    event.ignore("modem_message", activate)
end

return alarm