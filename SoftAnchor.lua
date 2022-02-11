-- Soft Anchor
-- Numeric Input
--  1 = Target X    = TGT
--  2 = Target Y
--  3 = Compas      = CPS
--  4 = GPS X       = GPS
--  5 = GPS Y
--  6 = Front Pivot = NGF
--  7 = Max Throttle Dist
-- Boolean Input
-- 1 = Enabled      = ACT

-- Numeric Output
--  1 = Front Pivot
--  2 = Front Motor
--  3 = Rear Motor

-- PROPERTIES
-- NOR = north vector
-- PI2 = 2pi
-- pi4 = pi/4
-- DIR = direction ship should point
function init()
  NOR = v(0, 1)
  MTD=gn(7)
	load()
  if tick > 100 then
		func = calc
	end
end
function onTick()
  tick = tick + 1
	func()
end
function onDraw()
	screen.drawText(0,0,fmt("disp %.1f %.1f",DISP.x,DISP.y))
  screen.drawText(0,10,fmt("ahead %.1f %.1f",AHEAD.x,AHEAD.y))
  screen.drawText(0,20,fmt("mf %.2f",mf))
  screen.drawText(0,30,fmt("mr %.2f",mr))
  screen.drawText(0,40,fmt("ab %.4f",PRINTAB))
end
function load()
  --TGT=v(gn(1),gn(2))
  CPS=gn(3)
  GPS=v(gn(4),gn(5))
  AHEAD = rot(NOR, CPS * PI2)
  PORT = perp(AHEAD)
  NGF=gn(6)
  DISP = sub(TGT, GPS)
  act = gb(1)
  if act and not ACT then
    DIR = AHEAD
    TGT = v(gn(4),gn(5))
  end
  ACT=act
end
function calc()
	load()
  if not ACT then
    sn(1,wrap(-NGF))
    sn(2,0)
    sn(3,0)
    return
  end
  vec, dist = nor(DISP)
  ab, dp = ang(vec,AHEAD)
  s = -sign(dot(PORT,vec))
  ab = (ab / PI2) * s
  ab = wrap(ab-NGF)
  
  m  = 0
  if dist > 5 then
    if math.abs(ab) < 0.25 then
      m = 1 - ab * 4
    end
    m = (dist / MTD) * m
  end
  mf=m
  sn(1,ab)
  sn(2,m)
  
  ab,dp=ang(DIR,AHEAD)
  s = sign(dot(PORT,DIR))
  ab = (ab / PI2) * s
  PRINTAB=ab
  sn(3,ab)
  
  --801.69 12815.38
  --prfv = mul(vec, prfv)
  -- locv = rot(sub(prfv, VEL), -CPS * PI2) -- this is nice local acceleration vector
end
function v(x,y)return{x=x,y=y}end
function dot(a,b)return a.x*b.x+a.y*b.y end
function len2(a)return a.x*a.x+a.y*a.y end
function len(a)return math.sqrt(len2(a))end
--function nor(a)l = len(a)return v(a.x/l,a.y/l),l end
--function nor(a)l = len(a)return l>0 and v(a.x/l,a.y/l),l or v(0,0),0 end
--function nor(a)l = len(a) if l>0 then return v(a.x/l,a.y/l),l else return v(0,0),0 end end
--function nor(a) return l>0 and v(a.x/l,a.y/l) or v(0,0), l end
function nor(a)l=len(a)return l>0 and v(a.x/l,a.y/l) or v(0,0), l>0 and l or 0 end
function sub(a,b)return v(a.x-b.x,a.y-b.y)end
function mul(a,b)return v(a.x*b,a.y*b)end
function zero(a)return a.x==0 and a.y==0 end
function ang(a,b)if zero(a)or zero(b)then return 0,0 end dp=dot(a,b)return math.acos(clamp(dp/math.sqrt(len2(a)*len2(b)),-1,1)),dp end
function perp(a)return v(-a.y, a.x)end
function rot(a,r)ca=math.cos(r)sa=math.sin(r)return v(a.x*ca-a.y*sa,a.x*sa+a.y*ca)end
function clamp(a,b,c)return math.max(math.min(a,c),b)end
function finite(x) return x==x end
function wrap(a) return (a%1+1.5)%1-0.5 end
function sign(n) return n>=0 and 1 or-1 end
gn = input.getNumber
gb = input.getBool
sn = output.setNumber
sb = output.setBool
fmt=string.format
func = init
tick = 0
PI = math.pi
PI2 = PI * 2
PI4 = PI / 4
PRINTAB=0
mf=0
mr=0
TGT=v(0,0)
ACT=false