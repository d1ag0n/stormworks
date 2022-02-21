-- Cheat Electric
-- Numeric Input
--  1 = Motor RPS = RPS

-- Boolean Output
--   1 = Gearbox 1
-- ... to 10 add more if you must

function onTick()
  tick = tick + 1  
  tickDelta = tick - lastTick
  if tickDelta > 10 then
    rps = gn(1)
    if rps > 19 and gear < 11 then
      gear = gear + 1
      lastTick = tick
    end
  end
  for i = 1, 11 do
    sb(i, gear >= i)
  end
end
gn=input.getNumber
sb=output.setBool
gear = 0
tick = 0
lastTick = 0
rps = 0