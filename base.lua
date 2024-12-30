local component = require("component")
local colors = require("colors")
local sides = require("sides")
local base = {}

local player_input = sides.right
local machine_input = sides.top
local output = sides.left

function getPlayerInput(color) return component.redstone.getBundledInput(player_input, color) end

function getMachineInput(color) return component.redstone.getBundledInput(machine_input, color) end

function setOutput(color, value) component.redstone.setBundledOutput(output, color, value) end

function uh_oh() component.modem.broadcast(5042, "base", true) end

function nvm() component.modem.broadcast(5042, "base", false) end

function base.updateValues()
    for i=0,15 do
        setOutput(colors[i], getInput(colors[i]))
    end
end

function base.startup() base.updateValues() end

function base.shutdown()
    for i=0,15 do
        setOutput(colors[i], 0)
    end
end

return base