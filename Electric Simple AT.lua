-- Cheat Electric
-- Numeric Input
--  1 = Number of Gears
--  2 = Motor RPS = RPS

-- Boolear Output
--  1 = Gearbox 1
--  2 = Gearbox 2
--  3 = Gearbox 3
--  4 = Gearbox 4
--  5 = Gearbox 5

-- PROPERTIES
function onDraw() 
  screen.drawText(0,0,fmt("tick %.1f lastTick %.1f rps %.1f gear %.1f",tick,lastTick,rps,gear)) 
end
function onTick()
  tick = tick + 1  
  tickDelta = tick - lastTick
  if tickDelta > 10 then
    gearCount = gn(1)
    rps = gn(2)
    if rps > 19 and gear < gearCount then
      gear = gear + 1
      lastTick = tick
    else if rps < 1 and gear > 1 then
      gear = gear - 1
      lastTick = tick
    end
  end
  for i = 1, gearCount do
    sb(i, gear >= i)
  end
end
gn=input.getNumber
sb=output.setBool
gear = 0
tick = 0
lastTick = 0
fmt=string.format
rps = 0