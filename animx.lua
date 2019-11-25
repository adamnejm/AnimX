
---------------
--[[ TWEEN ]]--
---------------

--@include tween.txt

local tween = require("tween.txt")



---------------
--[[ ANIMX ]]--
---------------

--@name AnimX

local AnimX = {
    
    -- user configuration
    time = timer.realtime,
    cleanupOnDestroy  = true, -- perform additional cleanup incase user forgets to set the instance to nil
    acceptCustomKeys  = true, -- instances will inherit all provided keys, this might cause issues if you override keys like 'class'
    makeQueueSeamless = true, -- prevents pingpong element inside of a non-pingpong queue from inverting at finish for odd and greater than one iterations
    
    -- currently playing animations
    playing = {},
    
    -- avaiable states of animation
    STATUS = {
        STOPPED = 1, [1] = "stopped",
        PLAYING = 2, [2] = "playing",
        PAUSED  = 3, [3] = "paused",
    },
    
    -- unique id counter
    UID = 1,
    
}

local STATUS = AnimX.STATUS

local clamp  = math.clamp



----------------
--[[ UPDATE ]]--
----------------

AnimX.update = function()
    
    for k, v in pairs(AnimX.playing) do
        v:update()
    end
    
end



--------------
--[[ BASE ]]--
--------------

local AnimBase = class("AnimBase")


function AnimBase:initialize(data, suppressAutoplay)
    
    data = data or {}
    
    if AnimX.acceptCustomKeys then
        table.merge(self, data)
    end
    
            --[[ PUBLIC ]]--
    self.style       = data.style       or "linear"
    self.start       = data.start       or 0
    self.finish      = data.finish      or 1
    self.duration    = data.duration    or 1
    self.iterations  = data.iterations  or 1
    self.modifier1   = data.modifier1
    self.modifier2   = data.modifier2
    
    self.pingpong    = data.pingpong    or false
    self.autoplay    = data.autoplay    or false
    self.autodestroy = data.autodestroy or false
    self.wait        = data.wait        or false
    
    self.onUpdate    = data.onUpdate
    self.onStart     = data.onStart
    self.onFinish    = data.onFinish
    self.onIteration = data.onIteration
    
            --[[ PRIVATE ]]--
    self.status      = STATUS.STOPPED
    self.inverted    = false
    self.value       = self.start
    self.iteration   = 1
    self.progress    = 0
    self.started     = 0
    self.offset      = 0
    
    self.id   = AnimX.UID; AnimX.UID = AnimX.UID + 1
    self.name = self.class.name .."[".. self.id .."]"
    
    if self.autoplay and not suppressAutoplay then
        self:play(type(self.autoplay) == "number" and self.autoplay)
    end
    
end


--[[ PUBLIC METHODS ]]--

function AnimBase:play(wait, silent)
    
    if self.status == STATUS.PAUSED then
        self.started = AnimX.time() - self.offset
        self.offset  = 0
    else
        self.started = AnimX.time()
    end
    
    if wait or self.wait then
        self:halt(wait or self.wait)
    else
        
        AnimX.playing[self.id] = self
        
        if self.onStart and not silent then
            self:onStart(self.status)
        end
        
        self.status = STATUS.PLAYING
        
    end
    
end


function AnimBase:stop(update)
    
    self.status    = STATUS.STOPPED
    self.iteration = 1
    self.progress  = 0
    
    AnimX.playing[self.id] = nil
    
    if update then
        self.started = AnimX.time()
        self:update()
        self.started = 0
    end
    
end


function AnimBase:restart(silent)
    
    self.status    = STATUS.STOPPED
    self.iteration = 1
    self.progress  = 0
    self.inverted  = false
    
    self:play(nil, silent)
    
end


function AnimBase:pause(wait)
    
    if self.status == STATUS.STOPPED then
        return -- self:throw("Can't pause a stopped animation")
    end
    
    self.status = STATUS.PAUSED
    self.offset = AnimX.time() - self.started
    
    AnimX.playing[self.id] = nil
    
    if wait then
        self:halt(wait)
    end
    
end


function AnimBase:invert(dir)
    
    if dir ~= nil then
        self.inverted = dir
    else
        self.inverted = not self.inverted
    end
    
end


function AnimBase:destroy()
    
    self:stop()
    setmetatable(self, nil)
    
    if AnimX.cleanupOnDestroy then
        self.class = nil
        
        for k, v in pairs(self) do
            self[k] = nil
        end
    end
    
    --return nil
    
end


--[[ PRIVATE METHODS ]]--

function AnimBase:halt(amount)
    
    if not timer.exists(self.name) then
        timer.create(self.name, amount, 1, function()
            self:play(nil, false)
        end)
    else
        timer.adjust(self.name, amount, 1)
    end
    
end


function AnimBase:progressed()
    
    if self.iterations == 0 or self.iteration < self.iterations then
        self:iterated()
    else
        self:finished()
    end
    
end


function AnimBase:iterated()
    
    self.iteration = self.iteration + 1
    
    if self.onIteration then
        self:onIteration(self.iteration)
    end
    
    if self.pingpong then
        self:invert()
    end
    
    self:play(nil, true)
    
end


function AnimBase:finished()
    
    self:stop()
    
    if self.pingpong then
        self:invert()
    end
    
    if self.onFinish then
        self:onFinish(self.inverted)
    end
    
    if self.autodestroy then
        self:destroy()
    end
    
end


function AnimBase:update()
    
    self.progress = clamp(AnimX.time() - self.started, 0, self.duration) / self.duration
    self.value = self:step(self.inverted and 1-self.progress or self.progress)
    
    if self.onUpdate then
        self:onUpdate(self.value, self.progress)
    end
    
    if self.progress == 1 then
        self:progressed()
    end
    
end


--[[ META EVENTS ]]--

function AnimBase.__tostring(self)
    return self.name
end


function AnimBase.__concat(lhs, rhs)
    return tostring(lhs)..tostring(rhs)
end


--[[ MISC ]]--

function AnimBase:throw(msg, lvl)
    throw(self..": "..msg, lvl or 2)
end


function AnimBase:print(msg, ...)
    if msg then
        print(self..": "..msg, ...)
    else
        printTable(self)
    end
end



----------------
--[[ SIMPLE ]]--
----------------

local AnimSimple = class("AnimSimple", AnimBase)
AnimX.simple = AnimSimple


function AnimSimple:update()
    
    local prvValue = self.value
    self.progress = clamp(AnimX.time() - self.started, 0, self.duration) / self.duration
    self.value = self:step(self.inverted and 1-self.progress or self.progress)
    self.change = prvValue - self.value
    
    if self.onUpdate then
        self:onUpdate(self.value, self.progress, self.change)
    end
    
    if self.progress == 1 then
        self:progressed()
    end
    
end


function AnimSimple:step(progress)
    
    return tween[self.style](progress, self.start, self.finish - self.start, self.modifier1, self.modifier2)
    
end



---------------
--[[ MULTI ]]--
---------------

local AnimMulti = class("AnimMulti", AnimBase)
AnimX.multi = AnimMulti


function AnimMulti:step(progress)
    
    local result = {}
    
    for i = 1, #self.start do
        result[i] = tween[self.style](progress, self.start[i], self.finish[i] - self.start[i], self.modifier1, self.modifier2)
    end
    
    return result
    
end



------------------
--[[ PROPERTY ]]--
------------------

local AnimProperty = class("AnimProperty", AnimBase)
AnimX.property = AnimProperty


function AnimProperty:initialize(data)
    
    AnimBase.initialize(self, data)
    
    if not data.object then
        self:throw("This animation requires the 'object' parameter")
    end
    
    self.object = data.object
    
end


function AnimProperty:update()
    
    self.progress = clamp(AnimX.time() - self.started, 0, self.duration) / self.duration
    
    local progress = self.inverted and 1-self.progress or self.progress
    for k, v in pairs(self.start) do
        self.object[k] = tween[self.style](progress, self.start[k], self.finish[k] - self.start[k], self.modifier1, self.modifier2)
    end
    
    if self.onUpdate then
        self:onUpdate(self.object, self.progress)
    end
    
    if self.progress == 1 then
        self:progressed()
    end
    
end



-----------------
--[[ ELEMENT ]]--
-----------------

local AnimElement = class("AnimElement", AnimSimple)


function AnimElement:initialize(data, parent)
    
    -- if not set, following will be inherited form the parent
    data.pingpong = data.pingpong == nil and parent.pingpong or data.pingpong
    
    data.style      = data.style      or parent.style
    data.start      = data.start      or parent.start
    data.finish     = data.finish     or parent.finish
    data.duration   = data.duration   or parent.duration
    data.modifier1  = data.modifier1  or parent.modifier1
    data.modifier2  = data.modifier2  or parent.modifier2
    
    AnimBase.initialize(self, data, true)
    
    self.parent = parent
    
end


function AnimElement:update()
    
    local prvValue = self.value
    self.progress = clamp(AnimX.time() - self.started, 0, self.duration) / self.duration
    self.value = self:step(self.inverted and 1-self.progress or self.progress)
    self.change = prvValue - self.value
    
    if self.parent.onUpdate then
        self.parent:onUpdate(self.value, self.progress, self.change)
    end
    
    if self.onUpdate then
        self:onUpdate(self.value, self.progress, self.change, self.parent)
    end
    
    if self.progress == 1 then
        self:progressed()
    end
    
end


function AnimElement:finished()
    
    self:stop()
    
    self.parent:elementFinished()
    
    local suppressInvert
    if AnimX.makeQueueSeamless and not self.parent.pingpong then
        if self.iterations > 1 and self.iterations % 2 == 1 then
            suppressInvert = true 
        end
    end
    
    if self.onFinish then
        suppressInvert = self:onFinish(self.inverted)
    end
    
    if self.pingpong and not suppressInvert then
        self:invert()
    end
    
end



---------------
--[[ QUEUE ]]--
---------------

local AnimQueue = class("AnimQueue", AnimBase)
AnimX.queue = AnimQueue


function AnimQueue:initialize(data)
    
    AnimBase.initialize(self, data, true)
    
    self.queue = {}
    self.current = 1
    
    -- parse elements
    if not data.queue then
        self:throw("The 'queue' parameter is required")
    elseif #data.queue < 2 then
        self:throw("At least 2 queue elements are required")
    end
    
    for k, v in pairs(data.queue) do
        self.queue[k] = AnimElement(v, self)
    end
    
    
    if self.autoplay then
        self:play(type(self.autoplay) == "number" and self.autoplay)
    end
    
end


--[[ PRIVATE ]]--

function AnimQueue:elementFinished()
    
    local next = self.current + (self.inverted and -1 or 1)
    
    if self.queue[next] then
        self.queue[next]:play()
        self.current = next
    else
        
        if self.iterations == 0 or self.iteration < self.iterations then
            self:iterated()
        else
            self:finished()
        end
        
    end
    
end


function AnimQueue:iterated()
    
    self.iteration = self.iteration + 1
    
    if self.pingpong then
        
        self.inverted = not self.inverted
        
        -- prevent AnimElements without pingpong playing twice on iterations
        if not self.queue[self.current].pingpong then
            self.current = self.current + (self.inverted and -1 or 1)
        end
        
    else
        self.current = 1
    end
    
    local suppressPlay
    if self.onIteration then
        suppressPlay = self:onIteration()
    end
    
    self:play()
    
end


function AnimQueue:finished()
    
    if self.pingpong then
        self:invert()
    end
    
    if self.onFinish then
        self:onFinish()
    end
    
    if self.autodestroy then
        self:destroy()
    end
    
end


--[[ PUBLIC ]]--

function AnimQueue:play(wait, silent)
    
    local anim = self.queue[self.current]
    
    if anim.status == STATUS.PAUSED then
        anim.started = AnimX.time() - anim.offset
        anim.offset  = 0
    else
        anim.started = AnimX.time()
    end
    
    if wait or anim.wait then
        anim:halt(wait or anim.wait)
    else
        
        AnimX.playing[anim.id] = anim
        
        if self.onStart and not silent then
            self:onStart(anim.status)
        end
        self.status = STATUS.PLAYING
        
        if anim.onStart and not silent then
            anim:onStart(anim.status)
        end
        anim.status = STATUS.PLAYING
        
    end
    
end

function AnimQueue:stop(update)
    self.status = STATUS.STOPPED
    self.queue[self.current]:stop(update)
end


function AnimQueue:restart(silent)
    self.status = STATUS.STOPPED
    self.queue[self.current]:restart(silent)
end


function AnimQueue:pause(wait)
    self.status = STATUS.PAUSED
    self.queue[self.current]:pause(wait)
end


function AnimQueue:invert(dir)
    self.queue[self.current]:invert(dir)
end


function AnimQueue:destroy(cleanup)
    
    self:stop()
    
    for k, v in pairs(self.queue) do
        v:destroy()
    end
    
    setmetatable(self,nil)
    
    if AnimX.cleanupOnDestroy then
        self.queue = nil
        self.class = nil
        
        for k, v in pairs(self) do
            self[k] = nil
        end
        
    end
    
    return nil
    
end



---------------
--[[ TRANS ]]--
---------------

local AnimTrans = class("AnimTrans")


function AnimTrans:initialize(object, start, finish, style, duration, callback, step)
    
    self.object   = object
    self.start    = start
    self.finish   = finish
    self.duration = duration or 1
    self.callback = callback
    
    if type(style) == "table" then
        self.style     = style[1] or "linear"
        self.modifier1 = style[2]
        self.modifier2 = style[3]
    else
        self.style = style    or "linear"
    end
    
    self.step     = step
    self.progress = 0
    self.started  = AnimX.time()
    
    self.id = AnimX.UID; AnimX.UID = AnimX.UID + 1
    
    AnimX.playing[self.id] = self
    
end


function AnimTrans:update()
    
    self.progress = clamp(AnimX.time() - self.started, 0, self.duration) / self.duration
    self:step(progress, tween[self.style](self.progress, self.start, self.finish - self.start, self.modifier1, self.modifier2))
    
    if self.progress == 1 then
    
        if self.callback then
            self.callback()
        end
        
        AnimX.playing[self.id] = nil
        setmetatable(self, nil)
    end
    
end



----------------------
--[[ TRANSITIONS ]]--
----------------------

AnimX.move = function(object, start, finish, style, duration, callback)
    object = object or chip()
    start  = start  or object:getPos()
    finish = finish or object:getPos() + Vector(0,0,50)
    
    AnimTrans(object, start, finish, style, duration, callback,
    function(self, progress, tw)
        self.object:setPos(tw)
    end)
end

AnimX.rotate = function(object, start, finish, style, duration, callback)
    object = object or chip()
    start  = start  or object:getAngles()
    finish = finish or object:getAngles() + Angle(0,90,0)
    
    AnimTrans(object, start, finish, style, duration, callback,
    function(self, progress, tw)
        self.object:setAngles(tw)
    end)
end

AnimX.scale = function(object, start, finish, style, duration, callback)
    object = object or chip()
    start  = start  or Vector(1)
    finish = finish or Vector(2)
    
    AnimTrans(object, start, finish, style, duration, callback,
    function(self, progress, tw)
        self.object:setScale(tw)
    end)
end



-------------------
--[[ FUNCTIONS ]]--
-------------------

AnimX.lerp = function(r, v1, v2)
    return v1 * (1-r) + (v2 * r)
end


AnimX.bezier = function(r, v1, v2, c)
    return (1-r)^2 * v1 + (2 * (1-r) * r * v2) + r^2 * c
end



--------------------------
--[[ AUTHOR & LICENSE ]]--
--------------------------

--@author    Name
--@website   adamnejm.com
--@email     contact@adamnejm.com

-- This work is licensed under The Unlicense.
-- Read more about The Unlicense here: https://unlicense.org/

-- For source & updates please visit:  https://github.com/adamnejm/AnimX
-- You are free to use, share and modify this code without any restrictions
-- You are not obligated to credit me, but it's always appreciated ;)


return AnimX -- Have fun!
