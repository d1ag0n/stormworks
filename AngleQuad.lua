-- Nuke Drone Pilot
-- Numeric Input
--  1 = Front Angle FA
--  2 = Left Angle LA
--  3 = Down Angle DA
--  4 = Altitude = ELV
--  5 = GPS X
--  6 = GPS Y
--  7 = Compass CPS
--  8 = Desired Altitude = ALT
--  9 = Desired X
-- 10 = Desired Y
-- 11 
-- 12 
-- 13 
-- 14 

-- Numeric Output
--  1 = FL
--  2 = FR
--  3 = BL
--  4 = BR
--  5 = 
--  6 = 
--  7 = 
--  8 = 
--  9 = 
-- 10 = 
-- 11 = 
-- 12 = 

-- Bool Output
-- 1 = 

-- CONSTANTS
-- ACC = acceleration
-- NOR = north vector
-- PI2 = 2pi
-- pi4 = pi/4
-- AFX  = altitude factor
function init()
  ACC = 0.001
  ALT = 0
  POS = v(0, 0)
  NOR = v(0, 1)
  PI2 = math.pi * 2
  PI4 = math.pi / 4
  GPS = v(0, 0)
	load()
  head = CPS
  if tick > 100 then
		func = calc
	end
end
function onTick()
  tick = tick + 1
	func()
end
function load()
  FA=gn(1)
  LA=gn(2)
  DA=gn(3)
  ELV=gn(4)  
  gps=GPS
  GPS=v(gn(5),gn(6))
  VEL=sub(GPS,gps)
  CPS=gn(7)
  ALT = ALT + ((gn(8) - ALT) * 0.01)	
  x = gn(9)
  if x ~= 0 then
    POS = v(x,gn(10))
  else 
    POS = GPS
  end
end
function calc()
	load()
  disp = sub(POS, GPS)
  vec, dist = nor(disp)
  
  if dist < 10 then
    dist = dist * 0.01
  end
  prfv = math.sqrt(2 * ACC * clamp(dist, 0, 1000))    
  prfv = mul(vec, prfv)
  locv = rot(sub(prfv, VEL), -CPS * PI2)
  
  
  f = 10
  c = 3
  x = clamp(locv.x * f, -c, c)
  y = clamp(locv.y * f, -c, c)
  f = 0.001
  FL = (FL - ALT - x + y) * f
  FR = (FR - ALT + x + y) * f
  BL = (BL - ALT - x - y) * f
  BR = (BR - ALT + x - y) * f
  
  sn(1, FL)
  sn(2, FR)
  sn(3, BL)
  sn(4, BR)
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
gn = input.getNumber
gb = input.getBool
sn = output.setNumber
sb = output.setBool
func = init
tick = 0