-- Nuke Drone Pilot
-- Numeric Input
--  5 Desired Position X   = POS.x
--  6 Desired Position Y   = POS.y
--  7 Desired Altitude     = ALT
--  8 Altitude Front Left  = AFL
--  9 Altitude Front Right = AFR
-- 10 Altitude Back Left   = ABL
-- 11 Altitude Back Right  = ABR
-- 12 Compass              = CPS
-- 13 GPS x                = GPS.x
-- 14 GPS y                = GPS.y

-- Numeric Output
--  1 = Front Left
--  2 = Front Right
--  3 = Back Left
--  4 = Back Right
--  5 = left/right accel
--  6 = front/back accel
--  7 = direction

-- CONSTANTS
-- ACC = acceleration
-- NOR = north vector
-- PI2 = 2pi
-- pi4 = pi/4
-- AFX  = altitude factor
function init()
  ACC = 0.6
  NOR = v(0, 1)
  PI2 = math.pi * 2
  PI4 = math.pi / 4
  AFX = 0.1
  GPS = v(0, 0)
	load()
  head = CPS
  if tick > 60 then
		func = calc
	end
end
gFunc = fInit
tick = 0
function onTick()
  tick = tick + 1
	func()
end
function load()
  gps = GPS
  
  POS = v(gn(5), gn(6))
	ALT = gn(7)
	AFL = gn(8)
	AFR = gn(9)
	ABL = gn(10)
	ABR = gn(11)
  CPS = gn(12)
  GPS = v(gn(13), gn(14))
  
	VEL = sub(GPS, gps)
end
function calc()
	load()
  
  sn(1,(AFL - ALT) * AFX)
	sn(2,(AFR - ALT) * AFX)
	sn(3,(ABL - ALT) * AFX)
	sn(4,(ABR - ALT) * AFX)
  
  disp = sub(POS,GPS)
  vec,dist = nor(disp)
  prfv = math.sqrt(2 * ACC * clamp(dist, 0, 1000))
	prfv = mul(vec,prfv)
  locv = rot(sub(prfv, VEL), -CPS)
  sn(5, locv.x)
  sn(6, locv.y)
  
  if dist > 10 then
    head = CPS
    bow = rot(NOR, CPS * PI2)
    port = perp(bow)
    angle = ang(bow, vec) / twoPi
    if dot(port, vec) < 0 then
      angle = -angle
    end
  else 
    angle = (head - CPS + 0.5) % 1 - 0.5
	end
	sn(7, angle)
end
function v(x,y)return{x=x,y=y}end
function dot(a,b)return a.x*b.x+a.y*b.y end
function len2(a)return a.x*a.x+a.y*a.y end
function len(a)return math.sqrt(len2(a))end
function nor(a)l = len(a)return v(a.x/l,a.y/l),l end
function sub(a,b)return v(a.x-b.x,a.y-b.y)end
function mul(a,b)return v(a.x*b,a.y*b)end
function zero(a)return a.x==0 and a.y==0 end
function ang(a,b)if zero(a)or zero(b)then return 0,0 end dp=dot(a,b)return math.acos(clamp(dp/math.sqrt(len2(a)*len2(b)),-1,1)),dp end
function perp(a)return v(-a.y, a.x)end
function rot(a,r)ca=math.cos(r)sa=math.sin(r)return v(a.x*ca-a.y*sa,a.x*sa+a.y*ca)end
function clamp(a,b,c)return math.max(math.min(a,c),b)end
function gn(n)return input.getNumber(n)end
function gb(n)return input.getBool(n)end
function sn(i,n)output.setNumber(i,n)end
function sb(i,n)output.setBool(i,n)end