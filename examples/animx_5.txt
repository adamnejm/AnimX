--@name AnimX Example 5
--@author Name
--@client
--@include ../animx.txt

--[[
    Uses Queue Animation to make a hologram jump, stretch based
    on change in value and rotate with separate Transition Animation
--]]

local AnimX = require("../animx.txt")
hook.add("tick", "", AnimX.update)

local holo  = holograms.create(chip():getPos(), Angle(), "models/holograms/cube.mdl")

AnimX.queue({
    iterations = 0,
    autoplay   = true,
    queue      =
    {
        {
            style = "outElastic",
            start = 0,
            finish = 1,
            duration = 0.8,
            pingpong = true,
            iterations = 2,
            onUpdate = function(self, value)
                holo:setPos(chip():getPos() + AnimX.lerp(value, Vector(0,0,8), Vector(0,0,4)))
                holo:setScale(AnimX.lerp(value, Vector(1,1,1.4), Vector(1.3,1.3,0.75)))
            end,
            
        },
        {
            style = "outSine",
            duration = 0.3,
            start = Vector(0,0,8),
            finish = Vector(0,0,60),
            iterations = 2,
            pingpong = true,
            smoothChange = 0, -- custom key (only avaiable when AnimX.acceptCustomKeys is set to true)
            onUpdate = function(self, value, progress, change)
                self.smoothChange = AnimX.lerp(0.5, math.abs(change.z)/5, self.smoothChange)
                holo:setPos(chip():getPos() + value)
                holo:setScale(Vector(1,1,1+self.smoothChange))
            end,
            onStart = function()
                AnimX.rotate(holo, holo:getAngles(), holo:getAngles() + Angle(0,90,0), "outCubic", 0.8)
            end
        }
    }
})
