--@name AnimX Example 1
--@author Name
--@client
--@include ../animx.txt

--[[
    Basic animation moving a hologram back and forth 3 times
--]]

local AnimX = require("../animx.txt")
hook.add("tick", "", AnimX.update)

local holo  = holograms.create(chip():getPos(), Angle(), "models/holograms/cube.mdl")

local myAnim
myAnim = AnimX.simple({
    style      = "inOutSine",
    start      = chip():getPos(),
    finish     = chip():getPos() + chip():getRight()*50,
    iterations = 3,
    pingpong   = true,
    
    onStart = function(self, prvStatus)
        print("Started")
    end,
    
    onIteration = function(self, iteration)
        print("Iteration: "..iteration)
    end,
    
    onFinish = function(self, inverted)
        myAnim = myAnim:destroy()
    end,
    
    onUpdate = function(self, value, iteration, change)
        holo:setPos(value)
    end
    
})

myAnim:play()
