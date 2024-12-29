local component = require("component")
local event = require("event")
local sides = require("sides")
local os = require("os")
local alarm = {}

function activate()
    component.redstone.setOutput(sides.top, 15)
end

function deactivate()
    component.redstone.setOutput(sides.top, 0)
end

function alarm.arm()
    component.modem.open(5042)
    while (true) do
        local _, _, _, _, _, on = event.pull("modem_message")
        if (on) then component.redstone.setOutput(sides.top, 15)
        else component.redstone.setOutput(sides.top, 0) end
    end
end

return alarm