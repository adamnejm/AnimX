--@name AnimX Example 4
--@author Name
--@client
--@include ../animx.txt

--[[
    Queues are amazing and the elements inherit properties from their parents!
--]]

local AnimX = require("../animx.txt")
hook.add("tick", "", AnimX.update)

local holo  = holograms.create(chip():getPos(), Angle(), "models/holograms/cube.mdl")

AnimX.queue({
    style = "inOutBack",
    duration = 0.5,
    iterations = 0,
    autoplay = true,
    holosCreated = false, -- custom key
    queue = {
        
        {
            start  = Vector(0,0,0),
            finish = Vector(50,0,0),
        },
        {
            start  = Vector(50,0,0),
            finish = Vector(50,50,0),
            pingpong = true,
            iterations = 3,
        },
        {
            start  = Vector(50,50,0),
            finish = Vector(0,50,0),
            style = "inOutSine",
            duration = 1,
        },
        {
            start  = Vector(0,50,0),
            finish = Vector(0,0,0),
        },
        
    },
    
    onStart = function(self, prvStatus)
        if holosCreated then return end
        holosCreated = true
        
        for id, element in pairs(self.queue) do
            element.holo = holograms.create(chip():getPos() + element.finish + Vector(0,0,5), Angle(), "models/holograms/cube.mdl", Vector(0.5))
            element.holo:setColor(Color(360/#self.queue*id,1,1):hsvToRGB())
            
            element.onUpdate = function(self, value, iteration, change, parent)
                self.holo:setPos(chip():getPos() + value + Vector(0,0,5))
            end
        end
    end,
    
    onUpdate = function(self, value, iteration, change)
        holo:setPos(chip():getPos() + value)
    end,
    
})

