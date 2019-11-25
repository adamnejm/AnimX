--@name AnimX Example 3
--@author Name
--@client
--@include ../animx.txt

--[[
    This will animate keys of an object / table, useful for UI and similar stuff
--]]

local AnimX = require("../animx.txt")
hook.add("tick", "", AnimX.update)

local holo  = holograms.create(chip():getPos(), Angle(), "models/holograms/cube.mdl")

local myObject = {
    name = "Object",
    pos  = Vector(0,0,0),
    age  = 0,
}


AnimX.property({
    object      = myObject,
    start       = { pos = Vector(0,0,0),  age = 0  },
    finish      = { pos = Vector(50,0,0), age = 78 },
    autoplay    = true,
    autodestroy = true,
    
    onUpdate = function(self, value, iteration)
        holo:setPos(chip():getPos() + myObject.pos)
    end,
    
    onFinish = function(self)
        print(myObject.name.." died of an old age at "..self.object.age)
    end,
    
})

