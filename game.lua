-- title:   Astroflora
-- author:  EnigmA (Loqor, MagicMan(?))
-- desc:    Astroflora is a space-themed retro botany game developed by EnigmA focused on collecting flora and fauna from around multiple planets, galaxies, and asteroids.
-- site:    https://loqor.github.io/ & https://magicman.github.io/
-- license: Apache License 2.0
-- version: 0.1
version = "1.0"
-- script:  lua
-- menu: MAIN_MENU SPACE SETTINGS

--##############################--TODO--##############################--
-- ttri() for rotating the temporary ship/later on the player around planets/asteroids/astral bodies/ships.
-- Make planet sprites or generate them with code.
-- Make asteroid sprites or generate them with code.
-- Make <astral body> sprites or generate them with code, you get the point.
-- Make a map for the inside of a ship where you can view achievements and what you've collected on your travels.
-- Create general gameplay (hey I used a different word than make :D).
-- [Comments started at: 0100 hours, US Central Time -=- Comments ended at: 0200 hours, US Central Time]

function BOOT()

  gamemenu = "mainmenu"

  gravity  = 0.2

  screenlist = {
    "mainmenu",
    "space",
    "first-level"
  }

  mapcontent = {
		entitylist = {
			player,
		},
	}

  spaceship = {
    x=68,
    y=120,
    movespeed=0.2,
    maxspeed = 5,
    maxaccel = 1,
    decelspeed = 0.98,
    turnfactor = 0.5,

    angle = 0,
    velocity = 0,
    angularvelocity = 0,
  }

  player = {
    x=0,
    y=128 - 16,
    w = 16,
    h = 16,
    movespeed=0.2,
    maxspeed = 5,
    maxaccel = 1,
    decelspeed = 0.98,
    flip = false,

    dogravity = true,
    dotilecollide = {true, true, true},
    colliding = false,
    vx = 0,
    vy = 0,
  }

  block = {
    x = 0,
    y = 0,
    w = 8,
    h = 8,
  }

  circlex = 0
  circley = 0
  circleradius = 50
  circlesides = 15

  t=0
  cam={x=120,y=68,rx=68,ry=120}

  background = {}
  bgcolours = {
    1,2,0
  }

  stars = {}

  math.randomseed(tstamp())

  for x=1,80 do
    if background[x-1] and math.random(1,10) > 2 then
      preval = background[x-1]
      value = {math.random(
        preval[1]-10,
        preval[1]+10)*2,
        
        math.random(preval[2]-25,
        preval[2]+25)*2,

        math.random(5,30),
        
        bgcolours[math.random(1,3)]}
    else
      value = {math.random(0,120)*2,math.random(0,68)*2,math.random(10,40),
      bgcolours[1]}
    end

    table.insert(background, value)
  end

  for x = 1,70 do
    table.insert(stars, {math.random(1,120),math.random(1,68)})
  end
  starseed = math.random(1,100)
end

function solid(x,y)
	return fget(mget((x//8) + ((maplist[maplist.current][1]-1)*30),(y)//8),0)
end

function rspr(sx,sy,scale,angle,mx,my,mw,mh,key,useMap) --I promise I didn't steal this :(

  --  this is fixed , to make a textured quad
  --  X , Y , U , V
  local sv ={{-1,-1, 0,0},
             { 1,-1, 1,0},
             {-1,1,  0,1},
             { 1,1,  1,1}}

	local rp = {} --  rotated points storage

  --  the scale is mw ( map width ) * 4 * scale 
  --  mapwidth is * 4 because we actually want HALF width to center the image
  local scalex = (mw<<2) * scale
  local scaley = (mh<<2) * scale
  --  rotate the quad points
  for p=1,#sv do 
    -- apply scale
    local _sx = sv[p][1] * scalex 
		local _sy = sv[p][2] * scaley
    -- apply rotation
		local a = angle
		local rx = _sx * math.cos(a) - _sy * math.sin(a)
		local ry = _sx * math.sin(a) + _sy * math.cos(a)
    -- apply transform
    sv[p][1] = rx + sx
    sv[p][2] = ry + sy
    -- scale UV's 
    sv[p][3] = (mx<<3) + (sv[p][3] * (mw<<3))
    sv[p][4] = (my<<3) + (sv[p][4] * (mh<<3))
  end
  -- draw two triangles for the quad
  textri( sv[1][1],sv[1][2],
          sv[2][1],sv[2][2],
          sv[3][1],sv[3][2],
          sv[1][3],sv[1][4],
          sv[2][3],sv[2][4],
          sv[3][3],sv[3][4],
          useMap,key)

  textri( sv[2][1],sv[2][2],
          sv[3][1],sv[3][2],
          sv[4][1],sv[4][2],
          sv[2][3],sv[2][4],
          sv[3][3],sv[3][4],
          sv[4][3],sv[4][4],
          useMap,key)
end


-- Makes a planet that would be walkable, not fly-to-able.
function makePlanet(x,y,radius,sides,UVx,UVy,UVw,UVh)

  --div angle by 360 to get sides, basic maths
  local angletemp = math.rad(360/sides)
  local angle = angletemp

  --gets xy coordinates for the two outer verts. Its duplicated, hence the angle+angle bit. Again just transposes point based on radius to get distance
  local lx = radius * math.cos(angletemp) + radius
  local ly = radius * math.sin(angletemp) + radius
  local rx = radius * math.cos(angletemp+angletemp) + radius
  local ry = radius * math.sin(angletemp+angletemp) + radius

  --...What? Bro is not cooking.
  --8,0 -> 16,8

  local planet = {} -- Stores the necessary ttri() values.
  for e = 1,sides do
    local ax = x + radius + (lx-radius)*math.cos(angle)-(ly-radius)*math.sin(angle) --similar, but now corrects the offset left/right/up/down etc to correct point
    local ay = y + radius + (lx-radius)*math.sin(angle)+(ly-radius)*math.cos(angle) --also adds offset of x and y
    local aax = x + radius + (rx-radius)*math.cos(angle)-(ry-radius)*math.sin(angle) 
    local aay = y + radius + (rx-radius)*math.sin(angle)+(ry-radius)*math.cos(angle)
    radiusx = radius+x
    radiusy = radius+y
    --The UV directions are weird ok, but it works
    table.insert(planet, {ax, ay, aax, aay, radiusx, radiusy, UVx+UVw, UVy, UVx, UVy, UVx+(UVw/2), UVy+UVh}) -- Cheeky little table.insert() which is almost completely unnecessary.
    angle = angle+angletemp
  end
  
  return planet,radius
  --radius is needed for stuff, planet is only ran on generation, they should need to be recalculated, so we can just return its vert data - nuh uh i fixed it also i made new method for a flower :)
  
    
end

function makeFlower(x,y,radius,sides,UVx,UVy,UVw,UVh)
  local angletemp = math.rad(360/sides)
  local angle = angletemp
  local lx = radius * math.cos(angletemp) + radius
  local ly = radius * math.sin(angletemp) + radius
  local rx = radius * math.cos(angletemp+angletemp) + radius
  local ry = radius * math.sin(angletemp+angletemp) + radius
  local flower = {}
  for e = 1,sides do
    local ax = x + radius + (lx-radius)*math.cos(angle)-(ly-radius)*math.sin(angle)
    local ay = y + radius + (lx-radius)*math.sin(angle)+(ly-radius)*math.cos(angle)
    local aax = x + radius + (rx-radius)*math.cos(angle)-(ry-radius)*math.sin(angle) 
    local aay = y + radius + (rx-radius)*math.sin(angle)+(ry-radius)*math.cos(angle)
    radiusx = radius+x
    radiusy = radius+y
    table.insert(flower, {ax, ay, aax, aay, radiusx, radiusy, UVx+UVw, UVy, UVx, UVy, UVx+(UVw/2), UVy+UVh})
    angle = angle+angletemp
  end
  return flower,radius
end

function shipvelocity()
  

  spaceship.angle = spaceship.angle + spaceship.angularvelocity
  if spaceship.angle > 360 then
    spaceship.angle = spaceship.angle-360
  elseif spaceship.angle < -360 then
    spaceship.angle = spaceship.angle+360
  end

  --calculates new position
  --spaceship uses an angle, direction movement system
  --left right is controlled by angular velocity

  spaceship.x = spaceship.velocity*math.cos(math.rad(spaceship.angle)) + spaceship.x

  spaceship.y = spaceship.velocity*-math.sin(math.rad(spaceship.angle)) + spaceship.y

  spaceship.velocity = spaceship.velocity * spaceship.decelspeed
  spaceship.angularvelocity = spaceship.angularvelocity * 0.925

  spaceship.turnfactor = 0.5

  --WIP easing shit, needs to be changed if can make better
  --no I won't explain :)
  spaceship.turnfactor = math.abs((spaceship.movespeed - 0.5) / (5 - 0.5)*3)
  spaceship.movespeed = math.abs((spaceship.velocity - 0.5) / (5 - 0.5) / 6)
  if spaceship.movespeed > 0.05 then spaceship.movespeed = 0.05 end
  if spaceship.turnfactor > 0.5 then spaceship.turnfactor = 0.5 end
end

function collideTile()
	for _, sp in pairs(mapcontent.entitylist) do

		sp.colliding = {false,false,false}

		floor={nil}
		roof={nil}
		side={nil}
		side2={nil}
		if sp.dotilecollide[1] then floor = {solid(sp.x+2, sp.y+sp.vy+8), solid(sp.x+6, sp.y+sp.vy+8)}  end
		if sp.dotilecollide[2] then roof = {solid(sp.x+2, sp.y+sp.vy), solid(sp.x+6, sp.y+sp.vy)} end
		if sp.dotilecollide[3] then 
			side = {solid(sp.x+sp.vx+1, sp.y+2), solid(sp.x+sp.vx+1, sp.y+6)}
			side2 = {solid(sp.x + sp.vx+6, sp.y+2), solid(sp.x + sp.vx+6, sp.y+6)}
		end
		
				--floor collision
			if floor[1] or floor[2] then
				
				sp.vy = 0
				if (solid(sp.x+2,sp.y+8) and solid(sp.x+6,sp.y+8)) and (sp.y+sp.vy+8) % 8 ~= 0 then
					sp.y = sp.y - (sp.y+sp.vy+8) % 8
				end
				sp.colliding[1] = true
			else --apply gravity
				if sp.dogravity then
					sp.vy = sp.vy+(sp.gravity)
					sp.colliding[1] = false
				end
				
			end
		--roof collision
		if roof[1] or roof[2] then
			sp.vy = math.abs(sp.vy)
			sp.colliding[2] = true
		else
			sp.colliding[2] = false
		end
		--side collision
		if side[1] or side[2] or side2[1] or side2[2] then
			sp.vx = 0
			sp.colliding[3] = true
		else
			sp.colliding[3] = false
		end
	end
end

function playerVelocity()

  for _,sprite in pairs(mapcontent.entitylist) do
		if math.abs(sprite.vy) > (4.5 ) then
			if sprite.vy < 0 then sprite.vy = (-4.5 ) else sprite.vy = (4.5) end
		end


		sprite.x = sprite.x + (sprite.vx)
		sprite.y = sprite.y + (sprite.vy)



		sprite.vx = sprite.vx*(sprite.dx )
		if math.abs(sprite.vx) < (0.05 ) then sprite.vx = 0 end
	end
	--for _,sprite in pairs(mapcontent.interactablelist) do
	--	if sprite.canmove then
	--		if math.abs(sprite.vy) > (4.5 ) then
	--			if sprite.vy < 0 then sprite.vy = (-4.5 ) else sprite.vy = (4.5) end
	--		end


	--		sprite.x = sprite.x + (sprite.vx)
	--		sprite.y = sprite.y + (sprite.vy)



	--		sprite.vx = sprite.vx*(sprite.dx )
	--		if math.abs(sprite.vx) < (0.05 ) then sprite.vx = 0 end
	--	end
	--end
end

function flyShipAndMove()

  -- This is pretty much just basic movement code for a ship with accel and deccel. Can be applied to other
  --moving objects/entities/the player.

  -- Press A or Left Arrow to move to the left. Crazy, I know.
  if btn(2) or key(01) then
    spaceship.angularvelocity = spaceship.angularvelocity - spaceship.turnfactor
  end

  -- Press D or Right Arrow to move to the right. Nuts, I'm aware.
  if btn(3) or key(04) then
    spaceship.angularvelocity = spaceship.angularvelocity + spaceship.turnfactor
  end

  -- Press W or Up Arrow to move to up/forward. Insane, I understand.
  if btn(0) or key(23) and spaceship.velocity > -spaceship.maxspeed then
    spaceship.velocity = spaceship.velocity - spaceship.movespeed
  end

  -- Press S or Bottom Arrow to move down/backward. Crikey, I gets it.
  if btn(1) or key(19) and spaceship.velocity < spaceship.maxspeed then
    spaceship.velocity = spaceship.velocity + 0.01
  end
end

function movePlayer()

  if btn(3) or key(04) then
    if player.vx < player.maxspeed then
      player.vx = player.vx + 0.3
    end
    player.flip = false
  end

  if btn(2) or key(01) then
    if player.vx < -player.maxspeed then
      player.vx = player.vx - 0.3
    end
    player.flip = true
  end

  if btn(0) or key(23) and player.colliding[1] then
    player.vy = player.vy-0.3
  end
end

--Very cool function for drawing the planet with modifiable radius and position ;)
function planetSprite()
  local plnt = {}
    plnt.planet, plnt.radius = makePlanet(circlex+cam.ry,circley+cam.rx,circleradius,circlesides,8,0,8,32)
  return plnt
end

function lerp(a,b,t) 
  return (1-t)*a + t*b 
end

function drawMainMenu()
  vbank(0)
  poke(0x3FC0, 1)
  cls(0)
  for _,val in pairs(background) do
    circ(table.unpack(val))
  end
  
  for _,val in pairs(stars) do
    local x = val[1] *2
    local y = val[2] *2
    if math.random(1,1000) > 1 then
      line(x,y-1,x,y+1,6)
      line(x-1,y,x+1,y,6)
    else
      pix(x,y,6)
    end
  end

  rspr(220,50,1,math.rad(45),2,16,2,2,0,false)
  rspr(208,62,1,math.rad(45),2,18,2,2,0,false)
  
  for _,val in pairs(planetSprite().planet) do
    ttri(table.unpack(val))
  end

  for i=t%8,360,8 do
    line(i,136,150,135-i,15)
    t=t+0.01
  end

  tx = 0
  ty = 0

  flwrx = tx + 6
  flwry = ty - 8

  flower = makeFlower(flwrx, flwry, 32, 5, 0, 160, 8, 8)

  for _,val in pairs(flower) do 
    ttri(table.unpack(val))
  end

  vbank(1)
  cls(0)
  
  if Button(tx + 4, ty + 58, "NEW GAME", 8) and gmouse().left then
    gamemenu = "spaceship"
  end

  if Button(tx + 4, ty + 72, "[TEMP] SPACE GAME", 8) and gmouse().left then
    gamemenu = "space"
  end

  if Button(tx + 4, ty + 90, "EXIT", 12) and gmouse().left then
    gamemenu = "exit"
  end

  --Flower and mid part
  spr(321, flwrx + 24, flwry + 24, 0, 2, 0, 0)
  spr(336, tx, ty, 0, 2, 0, 0, 2, 2)
  spr(338, tx + 32, ty, 0, 2, 0, 0, 2, 2)
  spr(340, tx + 64, ty, 0, 2, 0, 0, 2, 2)

  --Surrounds and text like NEW GAME and EXIT because yes temporary ofc.
  spr(308, tx, ty + 57, 0, 1, 0, 0)
  print("NEW GAME", tx + 4, ty + 58, 15)
  spr(309, tx + 45, ty + 57, 0, 1, 0, 0)
  spr(292, tx, ty + 71, 0, 1, 0, 0)
  print("[TEMP] SPACE GAME", tx + 4, ty + 72, 8)
  spr(293, tx + 90, ty + 71, 0, 1, 0, 0)
  spr(323, tx, ty + 89, 0, 1, 0, 0)
  print("EXIT", tx + 4, ty + 90, 3)
  spr(324, tx + 21, ty + 89, 0, 1, 0, 0)

  print("Version: " ..version, 0, 124, 6, 0, 1, true)
  print("Astroflora (C) 2023, Loqor & MagicMan(?).", 0, 130, 6, 0, 1, true)
end

function Button(bx,by,text,colour)
	bh = 6
	bw = string.len(text)*5 + string.len(text)
	aw=1
	ah=1
	ax = gmouse().x
	ay = gmouse().y

	local output = ax<bx+bw and bx<ax+aw and ay<by+bh and by<ay+ah

	if output then
		spr(274,bx-6,by-2,00,1,1)
		spr(275,bx+bw-6,by-2,00,1,0)
		drawtextoutline(text,bx,by,9)
	end
	print(text,bx,by,colour)
	
	return output
end

function drawtextoutline(text,x,y,colour)
	print(text,x-1,y,colour)
	print(text,x+1,y,colour)
	print(text,x,y+1,colour)
	print(text,x,y-1,colour)
end

function drawSpace()

  vbank(0)
  poke(0x3FF8, 13)
  poke(0x3FFB, 4)
  poke(0x3FC0, 20)
  poke(0x3FC1, 15)
  poke(0x3FC2, 20)
  poke(0x3FC3, 20)
  poke(0x3FC4, 20)
  poke(0x3FC5, 30)
  poke(0x3FC6, 30)
  poke(0x3FC7, 25)
  poke(0x3FC8, 40)
  cls(0)
  spr(36, 114 + cam.ry, 120 + cam.rx, 0, 4, 0, 0, 2, 2)
  for _,val in pairs(background) do
    circ(table.unpack(val))
  end
  
  for _,val in pairs(stars) do
    local x = val[1] *2
    local y = val[2] *2
    if math.random(1,1000) > 1 then
      line(x,y-1,x,y+1,6)
      line(x-1,y,x+1,y,6)
    else
      pix(x,y,6)
    end
  end
  vbank(1)
  poke(0x3FFB, 4)
  cls(0)

  --if circlex > 0 or circlex <= 240 or circley > 0 or circley <= 136 then
  --    for _,val in pairs(planetSprite().planet) do 
  --      ttri(table.unpack(val))
  --  end
  --end
    
  spr(34, 114 + cam.ry, 120 + cam.rx, 0, 4, 0, 0, 2, 2)

  sprix = 1
  spriy = 8
  angle = 0

  rspr( spaceship.y+cam.ry,spaceship.x+cam.rx,1,math.rad(spaceship.angle),(sprix*2),spriy*2,2,2,0,false)


  -- Draws the sprite for the mouse cursor.
  spr(4,gmouse().x,gmouse().y,0,1)
end

function cameraMovement()
  cam.rx = lerp(cam.rx,68-spaceship.x,0.05)
  cam.ry = lerp(cam.ry,120-spaceship.y,0.05)
end

function TIC()
  if gamemenu == "mainmenu" then
    drawMainMenu()
  elseif gamemenu == "space" then
    flyShipAndMove()
    shipvelocity()
    cameraMovement()
    drawSpace()
    
    --print(p.x, 32, 32, 6)
    --print(p.y, 32, 40, 6)
    print("x: "..spaceship.x, 4, 4, 6)
    print("y: "..spaceship.y, 4, 12, 6)
    print("angle: "..spaceship.angle,4,20, 6)
    print("T factor: "..spaceship.turnfactor,4,28, 6)
    print("Vel: "..spaceship.movespeed,4,36, 6)
  elseif gamemenu == "exit" then
    exit()
  elseif gamemenu == "spaceship" then
    vbank(0)
    cls(0)
    vbank(1)
    cls(0)
    vbank(0)
    poke(0x3FC0, 156)
    poke(0x3FC1, 156)
    poke(0x3FC2, 156)
    poke(0x3FF8, 1)
    poke(0x3FFB, 0)
    map(0,0,30,17)

    movePlayer()

    collideTile()

    playerVelocity()

    animation = {
      idle = {self={384, 386, 388, 390}}
    }
    sprite = animation.idle.self[math.floor(t//10 % #animation.idle.self) + 1]
    spr(sprite, player.x, player.y, 0, 1, boolToVal(player.flip), 0, 2, 2)
    
    print("acceleration: "..player.vx, 4, 4, 6)
  end

    -- Exit the current game to console with "`"
    if key(44) then
      exit()
    end

    t=t+1
end

-- Mouse function ripped directly from my old game (magic's old code that *doesn't* suck, haha).
function gmouse()
	local m = {}
	m.x,m.y,m.left,m.middle,m.right,m.scrollx,m.scrolly = mouse()
	return m
end

function boolToVal(bool)
  if bool then
    return 1
  else
    return 0
  end
end










-- I hate that this is here (the <TILES> and whatever's below it).

-- <TILES>
-- 001:8888888888788778477447744744474444444424422442222222442244422422
-- 002:2636636222222222ccccccccccccccccccccccccaccccccaaaaaaaaaaaaaaaaa
-- 003:256225621111111123333333111111121aaaacaa133332221cccaaac11111122
-- 004:0000000000059000000000000202505005029020000000000009500000000000
-- 016:7778877777888877777887777778877777788777777887777778877777788777
-- 017:2222444413312422113122213112221312221213222112212112112221323111
-- 018:0000000000000000000000003233323312221222111111116162616211221122
-- 019:2122221213133131213113122316a132231ca132213113121313313121222212
-- 020:3332333320000002030320300012320000232100030230302000000233332333
-- 032:11111111112112213223322332333233333333e33ee33eeeeeee33ee333ee3ee
-- 033:2113112122212122112222113312221211121221222121212b2b2b211bb1bb1b
-- 034:00000000000006660006666600666555005555550666666605555555044aaaa5
-- 035:0000000066600000666660005556660055555500666666606555556055444550
-- 036:0000000000000000000011110011111101111111011111111111111111111111
-- 037:0000000000000000110000001111000011111000111110001111110011111100
-- 048:000000000000000000000000000000007777777777888777aca444a44a444aca
-- 049:b1bbb1bbbbbbbbbbabbbbbbaabbaabbaabaaaabaaaaaaaaaaaaaaaaaaaaaaaaa
-- 050:0aaaaa4405555555066666660055555500555555000566660000066600000000
-- 051:444caaa055aaa550655555606666660055555500666650006660000000000000
-- 052:1111111111111111111111111111111101111111011111110011111100001111
-- 053:1111110011111100111111001111110011111000111110001111000011000000
-- </TILES>

-- <SPRITES>
-- 002:0000000c000000cf000000ae000000ae000001af0f00a1ad0e00a1ac0dcaa1ac
-- 003:c0000000fc000000ea000000ea000000fa100000da1a00f0ca1a00e0ca1aacd0
-- 018:0cca11aaacca12a3acaa11a00acaa100acaaa001acca001fa0dd002e00fe0003
-- 019:aa11acc03a21acca0a11aaca001aaca0100aaacad200accad300dd0a3000ef00
-- 032:122244ddaa444ddd24444dd044488ddd244488d8aa4448d8122448d8112488dd
-- 033:00dd88ddddd84ddd8d44d88d4844d8444448d844244884441444442412244232
-- 034:000000000000000e0000000d00000e00000000dd00ef0000000dffff0e00dddd
-- 035:00000000e0000000d000000000e00000dd0000000000fe00ffffd000dddd00e0
-- 036:0700000087700000600000000600000060000000877000000700000000000000
-- 037:0000007000000778000000060000006000000006000007780000007000000000
-- 048:122a223312211233112111231121331331223333331211333111133131133331
-- 049:1121432111111331121131313333311311331111111333331111333311113333
-- 050:def00000ddffffff0ddeeeee000ddddd00000000000000000000000000000000
-- 051:00000fedffffffddeeeeedd0ddddd00000000000000000000000000000000000
-- 052:0d000000edd00000f00000000f000000f0000000edd000000d00000000000000
-- 053:000000d000000dde0000000f000000f00000000f00000dde000000d000000000
-- 064:0000003300000333000033330002323000012100000212000001100000011000
-- 065:0c044000a6c565500a5446504546646546566564046556400446644000044000
-- 067:0100000021100000300000000300000030000000211000000100000000000000
-- 068:0000001000000112000000030000003000000003000001120000001000000000
-- 080:000000000effe00000000000ef00fe0000000000deeeed0000000000de00ed00
-- 081:000000000efffe0000000000efff00000000000000eeed0000000000deeed000
-- 082:0000000078888700000000000077c000000a6c000077a0000000000000770000
-- 083:00000000efff000000000000ef00fe0000000000deee000000000000de00ed00
-- 084:000000000ffff00000000000ef00fe0000000000de00ed00000000000eeee000
-- 096:000005007777c65087888c000700000087700000070800000700000080000000
-- 097:0000000087000000780000007800000078000000875000008c65780078c88700
-- 099:000000007877000080087000807780007888000087785000780c65007808c000
-- 100:00000000008700000878000007087000885780007c65870080c8870070007800
-- 114:005000000c65700078c077007800870078007800780078008778870008877000
-- 128:00000efe0000ceee000a6cee000eaeed00eeed5500ed156600ddd15600ddd746
-- 129:fff00000efff0000eeee0000dddd000055500000666000006600000057000000
-- 130:0000000000000efe0000ceee000a6cee000eaeed00eeed5500ed156600ddd156
-- 131:00000000fff00000efff0000eeee0000dddd0000555000006660000066000000
-- 132:0000000000000efe0000ceee000a6cee000eaeed00eeeede00ed155500ddd166
-- 133:00000000fff00000efff0000eeee0000dddd0000eeee00005550000066600000
-- 134:00000efe0000ceee000a6cee000eaeed00eeed5500ed156600ddd15600dd8746
-- 135:fff00000efff0000eeee0000dddd000055500000666000006600000057000000
-- 144:00dd877500d7887700d76578000765770000722300000560000044000000cb00
-- 145:777000008778000088757000477570002338000005600000044000000cb00000
-- 146:00ddd74600dd877500d8777700d788780007657700076523000074400000cb00
-- 147:570000007770000087780000887800004775700023357000044800000cb00000
-- 148:00ddd75600dd877500d7887700d765780007657700007223000004400000cb00
-- 149:660000007770000087780000887570004775700023380000044000000cb00000
-- 150:00d8877500d7887700d76578000765770000722300000560000044000000cb00
-- 151:777800008778700088757000477570002338000005600000044000000cb00000
-- 232:00000ccc0000cccc000aaacc000aaacc000aaac5000aaac50aaaccc60aaaccc6
-- 233:ccccc000ccccccc0cccccca0aaaaaaa055555500115511001166110066666600
-- 234:0000055500005555000222550002225500022259000222590222555b0222555b
-- 235:55555000555555505555552022222220999999001199110011bb1100bbbbbb00
-- 236:00000ccc0000cccc000aaacc000aaaca000aaac5000aaac50aaa54c50aaa54c5
-- 237:ccaaa000ccccaaa0aaaaaaa0aaaaaaa055555500116611001166110066666600
-- 238:00000ccc0000cccc000aaacc000aaacc000aaac5000aaac50aaaccc60aaaccc6
-- 239:ccccc000ccccccc0cccccca0aaaaaaa055555500115511001166110066666600
-- 248:0aaaaccc0aaa5558000055660000056600000222000002220000122200001110
-- 249:6666600088880000778800007777550077776600022200000211000000110000
-- 250:022225550222bbb80000bbee00000bee00000111000001110000311100003330
-- 251:bbbbb00088880000448800004444bb004444ee00011100000133000000330000
-- 252:0aaaaccc0aaa5558000055660000056600000222000005520000455200006440
-- 253:6666600056580000748800007777550077776600055200000544000000460000
-- 254:0aaaaccc0aaa5558000055660000056600000222000002220000122200001110
-- 255:6666600088880000778800007777550077776600022200000211000000110000
-- </SPRITES>

-- <MAP>
-- 015:000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <FLAGS>
-- 000:00101010000000000000000000000000001010101000000000000000000000001010000010100000000000000000000010100000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1f0e1c3e21375845638c8fae9a6348d79b7df5edba647d34c0c74170377f9d303be4943ad2647117434b34859d7ec4c1
-- 001:1f0e1c3e21375845638c8fae9a6348d79b7df5edba647d34c0c74170377f9d303be4943ad2647117434b34859d7ec4c1
-- </PALETTE>

