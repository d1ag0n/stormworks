function onTick()
	gFunc()
end
function fInit()
	gAlt=0
	gGPS=v(0,0)
	V = v(0,0.1)
	N = v(0, 1)
	fLoad()
	sb(1, false)
	if gRPS > 19 then
		gFunc = fCalc
		gHeading = gCompass
		gTarget = gGPS
		gPilot = false
		gMapGPS = false
		gZoom = 10
	end
end
function fLoad()
	gRPS = gn(17)
	gMon = v(gn(1),gn(2))	
	gTouch = v(gn(3),gn(4))
	gTouched = gb(1) and not gTouchPre
    gTouchPre = gb(1)
	alt = gn(7)
	
	gAlt = gAlt + (alt-gAlt)*0.01
	gAltFL = gn(8)
	gAltFR = gn(9)
	gAltBL = gn(10)
	gAltBR = gn(11)
	
	gCompass = gn(12)
	gGPSLast = gGPS
	gGPS = v(gn(13),gn(14))
	gVelo = sub(gGPS, gGPSLast)
	gInput = v(gn(15),gn(16))
end
function fCalc()
	
	fLoad()
	if gTouched then
		x = gTouch.x
		y = gTouch.y
		z = 1
		if x < 11 then
			if y < 12 then
				gMapGPS = false
			elseif y < 24 then
				z = 0.8
			elseif y < 36 then
				z = 1.2
			elseif y < 48 then
				if gPilot then
					gPilot = false
				else 
					gPilot = true
					gTarget= fMap()
				end
			elseif y < 60 then
				gMapGPS = gInput
			end
		else
			m = fMap()
			x,y = map.screenToMap(m.x,m.y,gZoom,gMon.x,gMon.y,x,y)
			gMapGPS = v(x,y)
		end
		gZoom = clamp(gZoom*z,0.1,50)
	end
	af=0.01
	if gPilot then
		twoPi = math.pi*2
		piOver4 = math.pi/4
		
		bow = rot(N, gCompass * twoPi)
		port = perp(bow)
		vec = sub(gTarget, gGPS)
		angle = ang(bow, vec) / twoPi

		if dot(port, vec) < 0 then
			angle = angle * -1.0
		end
		sn(1,angle)

	else
		sn(1,(gHeading-gCompass+0.5)%1-0.5)		
	end
	
	sb(1, true)
	sb(2, gPilot)
	sn(3,(gAltFL-gAlt)*af)
	sn(4,(gAltFR-gAlt)*af)
	sn(5,(gAltBL-gAlt+0.1)*af)
	sn(6,(gAltBR-gAlt+0.1)*af)
end
function fMap()return gMapGPS and gMapGPS or gGPS end
gFunc = fInit
function onDraw()
	m=fMap()
	screen.drawMap(m.x, m.y, gZoom)
	screen.setColor(0,0,0,127)
	
	screen.drawLine(11,0,11,59)
	screen.drawLine(0,11,11,11)
	screen.drawLine(0,23,11,23)
	screen.drawLine(0,35,11,35)
	screen.drawLine(0,47,11,47)
	screen.drawLine(0,59,11,59)
	
	-- target
	screen.setColor(255,255,255,127)
	screen.drawCircle(5,5,3)
	screen.drawLine(5,1,5,10)
	screen.drawLine(1,5,10,5)
	
	--plus
	screen.drawLine(5,13,5,22)--v
	screen.drawLine(1,17,10,17)--h
	
	--minus
	screen.drawLine(1,29,10,29)
	
	--go
	if gPilot then
		screen.drawRectF(2,38,7,7)
	else
		screen.drawTriangleF(2,38,9,42,2,46)
	end
	--input
	screen.drawCircle(5,53,3)
	screen.setColor(0,255,0,127)
	screen.drawText(12,0,string.format("velo %0.2f", len(gVelo)))
end


function v(x,y)return{x=x,y=y}end
function dot(a,b)return a.x*b.x+a.y*b.y end
function len2(a)return a.x*a.x+a.y*a.y end
function len(a)return math.sqrt(len2(a))end
function sub(a,b)return v(a.x-b.x,a.y-b.y)end
function zero(a)return a.x==0 and a.y==0 end
function ang(a,b)if zero(a)or zero(b)then return 0,0 end dp=dot(a,b)return math.acos(clamp(dp/math.sqrt(len2(a)*len2(b)),-1,1)),dp end
function perp(a)return v(-a.y, a.x)end
function rot(a,r)ca=math.cos(r)sa=math.sin(r)return v(a.x*ca-a.y*sa,a.x*sa+a.y*ca)end
function clamp(a,b,c)return math.max(math.min(a,c),b)end
function gn(n)return input.getNumber(n)end
function gb(n)return input.getBool(n)end
function sn(i,n)output.setNumber(i,n)end
function sb(i,n)output.setBool(i,n)end