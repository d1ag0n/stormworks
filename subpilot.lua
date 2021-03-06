-- Nuke Drone Pilot
-- Numeric Input
--  5 Desired Position X   = POS.x   8748
--  6 Desired Position Y   = POS.y   7051
--  7 Desired Altitude     = ALT
--  8 
--  9 
-- 10 
-- 11 
-- 12 Compass              = CPS
-- 13 GPS x                = GPS.x
-- 14 GPS y                = GPS.y

-- Numeric Output
--  1 = 
--  2 = 
--  3 = 
--  4 = rudder
--  5 = left/right accel
--  6 = front/back accel
--  7 = direction
--  8 = distance
--  9 = preferred velocity
-- 10 = actual velo

-- Bool Output
-- 1 = steer compass

-- CONSTANTS
-- ACC = acceleration
-- NOR = north vector
-- PI2 = 2pi
-- pi4 = pi/4
-- AFX  = altitude factor
function init()
  ACC = 0.001
  NOR = v(0, 1)
  PI2 = math.pi * 2
  PI4 = math.pi / 4
  AFX = 0.01
  GPS = v(0, 0)
	load()
  head = CPS
  if tick > 100 then
		func = calc
	end
end
func = init
tick = 0
function onTick()
  tick = tick + 1
	func()
end
function load()
  gps = GPS
  GPS = v(gn(13), gn(14))
  x = gn(5)
  y = gn(6)
  if math.abs(x) > 1 then
    POS = v(x,y)
  else 
    POS = GPS
  end
	ALT = gn(7)
  CPS = gn(12)
  
  
	VEL = sub(GPS, gps)
  vec,dist = nor(VEL)
  sn(10,dist)
end
function calc()
	load()  
  disp = sub(POS,GPS)
  vec,dist = nor(disp)
  sn(8,dist)
  prfv = math.sqrt(2 * ACC * clamp(dist, 0, 1000))
  sn(9, prfv)
	prfv = mul(vec, prfv)
  locv = rot(sub(prfv, VEL), -CPS * PI2)
  
  velmul = -10
  if dist < 40 then
    velmul = -0.1
  end
  
  sn(5, clamp(locv.x*velmul,-1,1))
  sn(6, clamp(locv.y*velmul,-1,1))
  
  if dist > 30 then
    head = CPS
    bow = rot(NOR, CPS * PI2)
    port = perp(bow)
    angle = ang(bow, vec) / PI2
    if dot(port, vec) < 0 then
      angle = -angle
    end
    sb(1, false)
  else 
    angle = (head - CPS + 0.5) % 1 - 0.5
    sb(1, true)
	end
  if locv.y < 0 then
    sn(8, -angle)
  else
    sn(8, angle)
  end
	sn(7, angle)
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
gn = input.getNumber
gb = input.getBool
sn = output.setNumber
sb = output.setBool
function finite(x) return x==x end