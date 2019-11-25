--@name AnimX Example 6
--@author Name
--@client
--@include ../animx.txt

--[[
    Let's have some fun with bezier
--]]

local AnimX = require("../animx.txt")
hook.add("tick", "", AnimX.update)


local count = 15

local holos = {}
for i = 1, count do
    holos[i] = holograms.create(chip():getPos(), Angle(), "models/balloons/balloon_star.mdl", Vector(0.2))
    holos[i]:setColor(Color(360/count*i,1,1):hsvToRGB())
end

local pos = chip():getPos()

AnimX.multi({
    style  = "inOutBack",
    start  = { pos + Vector(0,-50,30), pos + Vector(0,30,60)  },
    finish = { pos + Vector(0,50,30),  pos + Vector(0,-30,60) },
    iterations = 0,
    pingpong = true,
    autoplay = true,
    
    onUpdate = function(self, value)
        for i = 1, count do
            holos[i]:setPos(AnimX.bezier(i/count, pos, value[1], value[2]))
        end
    end
    
})
