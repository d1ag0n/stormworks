-- Automatic Transmissions
-- Numeric Input
--  1 = Number of Gears = NOG
--  2 = Motor RPS       = RPS
--  3 = Upshift RPS     = UPS
--  4 = Downshift RPS   = DNS

-- Numeric Output
--  1 = Clutch Pressure

-- Boolean Output
--  1 = Gearbox 1
--  n = Gearbox Number of Gears

-- PROPERTIES
function onDraw() 
  screen.drawText(0,0,fmt("tick %.1f lastTick %.1f rps %.1f gear %.1f",tick,lastTick,rps,gear))
end
function onTick()
  tick = tick + 1
  tickDelta = tick - lastTick
  if tickDelta > 100 then
    NOG = gn(1)
    UPS = gn(3)
    DNS = gn(4)
    RPS = gn(2)
    if RPS > UPS and gear < NOG and clutch == 1 then
      shift = 1
      lastTick = tick
      neutral = 0
      clutch = 0.3
    elseif RPS < DNS then      
      if gear > 0 then
        clutch = 0
        neutral = 0
        shift = -1
        lastTick = tick
      else
        clutch = clutch - 0.016
        neutral = 1
      end
    else
      neutral = 0
    end
  end
  for i = 1, NOG do
    sb(i, gear >= i)
  end
  sn(1,clutch)
  if neutral == 0 then
    if gear == 0 then
      clutch = clamp(clutch + 0.008, 0, 1)
    else
      clutch = clamp(clutch + 0.05, 0, 1)
    end
  end
  gear = gear + shift
  shift = 0
end
function clamp(a,b,c)return math.max(math.min(a,c),b)end
neutral = 1
shift = 0
clutch = 0
gn=input.getNumber
o = output
sb=o.setBool
sn=o.setNumber
gear = 0
tick = 0
lastTick = 0
fmt=string.format
rps = 0
NOG = 0