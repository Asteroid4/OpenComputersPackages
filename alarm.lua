local component = require("component")
local event = require("event")
local sides = require("sides")
local os = require("os")
local alarm = {}

function alarm.arm()
    component.modem.open(5042)
    while (true) do
        local _, _, from, _, _, nickname, on = event.pull("modem_message")
        if (on) then
            component.redstone.setOutput(sides.top, 15)
            print(os.time() .. ": Alarm activated by " .. nickname .. ", true name " .. from .. "!")
        else
            component.redstone.setOutput(sides.top, 0)
            print(os.time() .. ": Alarm deactivated by " .. nickname .. ", true name " .. from .. "!")
        end
    end
end

return alarm