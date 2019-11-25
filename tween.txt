--@name Tween Library
--@author Tweener authors, Yuichi Tateno, Emmanuel Oga, Name

--[[
    
    -----------------------------------------------------------------------------
    
    Copyright (c) 2010, Emmanuel Oga.
    
    This work is licensed under the terms of the MIT license.
    For a copy, see https://github.com/EmmanuelOga/easing
    
    Modified for special use case by Name
    
    -----------------------------------------------------------------------------
    
    Visualisations of following functions can be found here:
    https://easings.net/en
    
    -----------------------------------------------------------------------------
    
    linear(t, b, c)             inQuad(t, b, c)             inCubic (t, b, c)
                                outQuad(t, b, c)            outCubic(t, b, c)
                                inOutQuad(t, b, c)          inOutCubic(t, b, c)
                                outInQuad(t, b, c)          outInCubic(t, b, c)
    
    inQuart(t, b, c)            inQuint(t, b, c)            inSine(t, b, c)
    outQuart(t, b, c)           outQuint(t, b, c)           outSine(t, b, c)
    inOutQuart(t, b, c)         inOutQuint(t, b, c)         inOutSine(t, b, c)
    outInQuart(t, b, c)         outInQuint(t, b, c)         outInSine(t, b, c)
    
    inExpo(t, b, c)             inCirc(t, b, c)             inBack(t, b, c, s)
    outExpo(t, b, c)            outCirc(t, b, c)            outBack(t, b, c, s)
    inOutExpo(t, b, c)          inOutCirc(t, b, c)          inOutBack(t, b, c, s)
    outInExpo(t, b, c)          outInCirc(t, b, c)          outInBack(t, b, c, s)
    
    outBounce(t, b, c)          inElastic(t, b, c, a, p)
    inBounce(t, b, c)           outElastic(t, b, c, a, p)
    inOutBounce(t, b, c)        inOutElastic(t, b, c, a, p)
    outInBounce(t, b, c)        outInElastic(t, b, c, a, p)
    
    -----------------------------------------------------------------------------
    
    t = time (0-1)                      s = strength
    b = beginning                       a = amplitude
    c = change (ending - beginning)     p = period
    
    -----------------------------------------------------------------------------
    
    All tweening methods work with object that can be added, divided or subtracted from each other
    Please note that not all modifiers behave correctly when dealing with types other than numbers
    
    -----------------------------------------------------------------------------
    
]]--


local pow  = math.pow
local sin  = math.sin
local cos  = math.cos
local pi   = math.pi
local sqrt = math.sqrt
local asin = math.asin
local abs  = math.abs


local function vecang(t, b, c)
  return (b * (1-t)) + (c * t)
end


local function linear(t, b, c)
  return c * t + b
end

local function inQuad(t, b, c)
  return c * pow(t, 2) + b
end

local function outQuad(t, b, c)
  return -c * t * (t - 2) + b
end

local function inOutQuad(t, b, c)
  t = t * 2
  if t < 1 then
    return c / 2 * pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

local function outInQuad(t, b, c)
  if t < 0.5 then
    return outQuad (t * 2, b, c / 2)
  else
    return inQuad((t * 2) - 1, b + c / 2, c / 2)
  end
end

local function inCubic (t, b, c)
  return c * pow(t, 3) + b
end

local function outCubic(t, b, c)
  t = t - 1
  return c * (pow(t, 3) + 1) + b
end

local function inOutCubic(t, b, c)
  t = t * 2
  if t < 1 then
    return c / 2 * t * t * t + b
  else
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end
end

local function outInCubic(t, b, c)
  if t < 0.5 then
    return outCubic(t * 2, b, c / 2)
  else
    return inCubic((t * 2) - 1, b + c / 2, c / 2)
  end
end

local function inQuart(t, b, c)
  return c * pow(t, 4) + b
end

local function outQuart(t, b, c)
  t = t - 1
  return -c * (pow(t, 4) - 1) + b
end

local function inOutQuart(t, b, c)
  t = t * 2
  if t < 1 then
    return c / 2 * pow(t, 4) + b
  else
    t = t - 2
    return -c / 2 * (pow(t, 4) - 2) + b
  end
end

local function outInQuart(t, b, c)
  if t < 0.5 then
    return outQuart(t * 2, b, c / 2)
  else
    return inQuart((t * 2) - 1, b + c / 2, c / 2)
  end
end

local function inQuint(t, b, c)
  return c * pow(t, 5) + b
end

local function outQuint(t, b, c)
  t = t - 1
  return c * (pow(t, 5) + 1) + b
end

local function inOutQuint(t, b, c)
  t = t * 2
  if t < 1 then
    return c / 2 * pow(t, 5) + b
  else
    t = t - 2
    return c / 2 * (pow(t, 5) + 2) + b
  end
end

local function outInQuint(t, b, c)
  if t < 0.5 then
    return outQuint(t * 2, b, c / 2)
  else
    return inQuint((t * 2) - 1, b + c / 2, c / 2)
  end
end

local function inSine(t, b, c)
  return -c * cos(t * (pi / 2)) + c + b
end

local function outSine(t, b, c)
  return c * sin(t * (pi / 2)) + b
end

local function inOutSine(t, b, c)
  return -c / 2 * (cos(pi * t) - 1) + b
end

local function outInSine(t, b, c)
  if t < 0.5 then
    return outSine(t * 2, b, c / 2)
  else
    return inSine((t * 2) - 1, b + c / 2, c / 2)
  end
end

local function inExpo(t, b, c)
  if t == 0 then
    return b
  else
    return c * pow(2, 10 * (t - 1)) + b - c * 0.001
  end
end

local function outExpo(t, b, c)
  if t == 1 then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t) + 1) + b
  end
end

local function inOutExpo(t, b, c)
  if t == 0 then return b end
  if t == 1 then return b + c end
  t = t * 2
  if t < 1 then
    return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
  end
end

local function outInExpo(t, b, c)
  if t < 0.5 then
    return outExpo(t * 2, b, c / 2)
  else
    return inExpo((t * 2) - 1, b + c / 2, c / 2)
  end
end

local function inCirc(t, b, c)
  return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

local function outCirc(t, b, c)
  t = t - 1
  return(c * sqrt(1 - pow(t, 2)) + b)
end

local function inOutCirc(t, b, c)
  t = t * 2
  if t < 1 then
    return -c / 2 * (sqrt(1 - t * t) - 1) + b
  else
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
  end
end

local function outInCirc(t, b, c)
  if t < 0.5 then
    return outCirc(t * 2, b, c / 2)
  else
    return inCirc((t * 2) - 1, b + c / 2, c / 2)
  end
end

local function inElastic(t, b, c, a, p)
  if t == 0 then return b end

  if t == 1  then return b + c end

  if not p then p = 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  t = t - 1

  return -(a * pow(2, 10 * t) * sin((t - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
local function outElastic(t, b, c, a, p)
  if t == 0 then return b end

  if t == 1 then return b + c end

  if not p then p = 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  return a * pow(2, -10 * t) * sin((t - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
local function inOutElastic(t, b, c, a, p)
  if type(b) ~= "number" then return vecang(inOutElastic(t,0,1,a,p),b,c) end
  if t == 0 then return b end

  t = t * 2

  if t == 2 then return b + c end

  if not p then p = 0.3 * 1.5 end
  if not a then a = 0 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c / a)
  end

  if t < 1 then
    t = t - 1
    return -0.5 * (a * pow(2, 10 * t) * sin((t - s) * (2 * pi) / p)) + b
  else
    t = t - 1
    return a * pow(2, -10 * t) * sin((t - s) * (2 * pi) / p ) * 0.5 + c + b
  end
end

-- a: amplitud
-- p: period
local function outInElastic(t, b, c, a, p)
  if t < 0.5 then
    return outElastic(t * 2, b, c / 2, a, p)
  else
    return inElastic((t * 2) - 1, b + c / 2, c / 2, a, p)
  end
end

local function inBack(t, b, c, s)
  if not s then s = 1.70158 end
  return c * t * t * ((s + 1) * t - s) + b
end

local function outBack(t, b, c, s)
  if not s then s = 1.70158 end
  t = t - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function inOutBack(t, b, c, s)
  if not s then s = 1.70158 end
  s = s * 1.525
  t = t * 2
  if t < 1 then
    return c / 2 * (t * t * ((s + 1) * t - s)) + b
  else
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
  end
end

local function outInBack(t, b, c, s)
  if t < 0.5 then
    return outBack(t * 2, b, c / 2, s)
  else
    return inBack((t * 2) - 1, b + c / 2, c / 2, s)
  end
end

local function outBounce(t, b, c)
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

local function inBounce(t, b, c)
  return c - outBounce(1 - t, b * 0, c) + b
end

local function inOutBounce(t, b, c)
  if t < 0.5 then
    return inBounce(t * 2, b * 0, c) * 0.5 + b
  else
    return outBounce(t * 2 - 1 , b * 0, c) * 0.5 + c * .5 + b
  end
end

local function outInBounce(t, b, c)
  if t < 0.5 then
    return outBounce(t * 2, b, c / 2)
  else
    return inBounce(t * 2 - 1, b + c / 2, c / 2)
  end
end



return {
  linear = linear,
  inQuad = inQuad,
  outQuad = outQuad,
  inOutQuad = inOutQuad,
  outInQuad = outInQuad,
  inCubic  = inCubic ,
  outCubic = outCubic,
  inOutCubic = inOutCubic,
  outInCubic = outInCubic,
  inQuart = inQuart,
  outQuart = outQuart,
  inOutQuart = inOutQuart,
  outInQuart = outInQuart,
  inQuint = inQuint,
  outQuint = outQuint,
  inOutQuint = inOutQuint,
  outInQuint = outInQuint,
  inSine = inSine,
  outSine = outSine,
  inOutSine = inOutSine,
  outInSine = outInSine,
  inExpo = inExpo,
  outExpo = outExpo,
  inOutExpo = inOutExpo,
  outInExpo = outInExpo,
  inCirc = inCirc,
  outCirc = outCirc,
  inOutCirc = inOutCirc,
  outInCirc = outInCirc,
  inElastic = inElastic,
  outElastic = outElastic,
  inOutElastic = inOutElastic,
  outInElastic = outInElastic,
  inBack = inBack,
  outBack = outBack,
  inOutBack = inOutBack,
  outInBack = outInBack,
  inBounce = inBounce,
  outBounce = outBounce,
  inOutBounce = inOutBounce,
  outInBounce = outInBounce,
}