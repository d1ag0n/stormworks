-- Simple Heli AP v1
-- Gyro Matches Seat Input
-- Right+ Left-
-- W+ S-
-- D+ A-
-- Tilt Sensors
-- Pitch Points Forward
-- Roll  Points Left
-- East- West+ North0
--math.atan(math.sin(left), math.sin(up))
-- DONT use (atan(sin(x*pi2)/sin(z*pi2))/pi2)*sgn(z)
-- USE (atan2(sin(x*pi2),sin(z*pi2))/pi2)
-- Numeric Input
--  1 = Pilot Pitch     = PP
--  2 = Pilot Yaw       = PY
--  3 = Pilot Roll      = PR
--  4 = Pilot Elevation = PE
--  5 = Compass         = CP
--  6 = GPS X           = G.x
--  7 = GPS Y           = G.y
--  8 = Target Local X  = T.x
--  9 = Target Local Y  = T.y
-- 10 = Altitude        = AL
-- 11 = Tilt Forward    = TF
-- 12 = Tilt Up         = TU
-- 13 = Tilt Left       = TL left- right+

-- Boolean Input
-- 1 = Enabled          = A

-- Numeric Output
--  1 = Pitch
--  2 = Yaw
--  3 = Roll
--  4 = Elevation

-- PROPERTIES
-- NR = north vector
-- PT = port side vector
-- HD = ahead vector
-- P2 = 2pi
-- P4 = pi/4
-- DC = Desired Compass
-- DA = Desired Altitude
-- G = last position
-- FA = first altitude
-- FG = first gps
-- FC = first compass
-- LA = last altitude
-- VL = local velocity vector
-- LT = last target
-- GL = last gps
-- ACC = MAX ACCELERATION
-- MTA = MAX TILT ANGLE
ACC=7
MTA=0.18
function onDraw()
  dt(0,0,fmt("First: Alt %.1f - x%.1f y%.1f - %.2f",FA,FG.x,FG.y,FC))
  dt(0,6,fmt("active: %s PP %.2f PY %.2f PR %.2f PE %.2f",tostring(A),PP,PY,PR,PE))
  dt(0,12,fmt("TL: %.2f TF %.2f loct x%.2f y%.2f",TL,TF,loct.x,loct.y))
  dt(0,18,fmt("D: x%.2f y%.2f - VL: x%.2f y%.2f",D.x,D.y,VL.x,VL.y))
end
function onTick()
  a=gb(1)
  LA=AL
  AL=gn(10)  
  GL=G
  G=v(gn(6),gn(7))
  
  CP=gn(5)
  if FA==0 and AL~=0 then FA=AL end
  if FC==0 and CP~=0 then FC=CP end
  if zero(FG) and not zero(G) then FG=G LT=G end
  if a then
    T=v(gn(8),gn(9))
    LT=T
    if zero(T) then LT=G T=LT end
    loct=rot(sub(G,T),CP*P2)
    HD=rot(NR,CP*P2)
    PT=perp(HD)
    VL=mul(rot(sub(GL,G),CP*P2),60)
    TU=gn(12)
    su=sin(TU)
    TF=tilt(gn(11),su)
    TL=tilt(gn(13),su)
    if not A then DC=CP DA=AL A=a end
    
    sd=50
    dx = abs(loct.x)
    sx = clamp(dx/sd,0.2,1)
    dx = sqrt(2 * dx * ACC) * sx
    
    dy = abs(loct.y)
    sy = clamp(dy/sd,0.2,1)
    dy = sqrt(2 * dy * ACC) * sy
    
    D = v(dx * sign(loct.x) - VL.x, dy * sign(loct.y) - VL.y)
    PP=(TF+accel(D.y))*10
    PY=wrap(CP-FC)*4
    PR=(accel(D.x)-TL)*10
    ale=FA-AL
    aale=math.abs(ale)
    PE=clamp(ale*.5,-5,5)
  else
    if A then LT=T end
    PP=gn(1)
    PY=gn(2)
    PR=gn(3)
    PE=gn(4)
  end
  A=a
  sn(1,PP)
  sn(2,PY)
  sn(3,PR)
  sn(4,PE)
end
function accel(n) return clamp(MTA*clamp(n/ACC,-1,1),-MTA,MTA) end
function v(x,y)return{x=x,y=y}end
function dot(a,b)return a.x*b.x+a.y*b.y end
function len2(a)return a.x*a.x+a.y*a.y end
function len(a)return math.sqrt(len2(a))end
function nor(a)l=len(a)return l>0 and v(a.x/l,a.y/l) or v(0,0), l>0 and l or 0 end
function sub(a,b)return v(a.x-b.x,a.y-b.y)end
function mul(a,b)return v(a.x*b,a.y*b)end
function zero(a)return eq(a,v(0,0))end
function ang(a,b)if zero(a)or zero(b)then return 0,0 end dp=dot(a,b)return math.acos(clamp(dp/math.sqrt(len2(a)*len2(b)),-1,1)),dp end
function perp(a)return v(-a.y, a.x)end
function rot(a,r)ca=math.cos(r)sa=sin(r)return v(a.x*ca-a.y*sa,a.x*sa+a.y*ca)end
function clamp(a,b,c)return math.max(math.min(a,c),b)end
function finite(x) return x==x end
function wrap(a) return (a%1+1.5)%1-0.5 end
function sign(n) return n>=0 and 1 or-1 end
function eq(a,b)return a.x==b.x and a.y==b.y end
function tilt(n,su)return math.atan(sin(n*P2),su)/P2 end
m=math
abs=m.abs
sin=math.sin
sqrt=m.sqrt
PI=m.pi
P2=PI*2
P4=PI/4
VL=v(0,0)
loct=v(0,0)
D=v(0,0)
AL=0
LA=0
TL=0
TF=0
turn=0
FA=0
FC=0
T=v(0,0)
LT=v(0,0)
NR=v(0, 1)
G=v(0,0)
FG=G
i=input
gn=i.getNumber
gb=i.getBool
sn=output.setNumber
fmt=string.format
PY=0
dt=screen.drawText