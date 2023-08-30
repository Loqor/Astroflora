-- title:   Astroflora
-- author:  EnigmA (Loqor, MagicMan(?))
-- desc:    Astroflora is a space-themed retro botany game developed by EnigmA focused on collecting flora and fauna from around multiple planets, galaxies, and asteroids.
-- site:    https://loqor.github.io/ & https://magicman.github.io/
-- license: Apache License 2.0
-- version: 0.1
-- script:  lua

--##############################--TODO--##############################--
-- ttri() for rotating the temporary ship/later on the player around planets/asteroids/astral bodies/ships.
-- Make planet sprites or generate them with code.
-- Make asteroid sprites or generate them with code.
-- Make <astral body> sprites or generate them with code, you get the point.
-- Make a map for the inside of a ship where you can view achievements and what you've collected on your travels.
-- Create general gameplay (hey I used a different word than make :D).
-- [Comments started at: 0100 hours, US Central Time -=- Comments ended at: 0200 hours, US Central Time]

-- I don't like the generity of "t" as a variable, but honestly, whatever. It's lua. F**king love lua.
t = 1

--Circle stuff should be put in a list/table/some sort of organized space because I don't like it here.
circlex = 70
circley = 20
circleradius = 50
circlesides = 12


-- If I see more variables defined here constantly, I will personally beat your ass. Lookin' at you, Magic boy.
function BOOT()

  -- Sets the default velocity values on BOOT() because yes and because I don't care about where it's set, I just want it set to 0 once.
  p.vx = 0
  p.vy = 0
end

-- L function used for drawing and rotation, also unused for some reason :)))))))) :insert clown emoji here:.
function rspr(sx,sy,scale,angle,mx,my,mw,mh,key,useMap) --I promise I didn't steal this :( | Hello, Loqor here, and yes, MagicMan(?) did steal this from MonstersGoBoom
  --because he (MagicMan(?)) sucks balls.

  -- This is fixed, to make a textured quad.
  -- X, Y, U, V
  local sv ={{-1,-1, 0,0},
             { 1,-1, 0.999,0},
             {-1,1,  0,0.999},
             { 1,1,  0.999,0.999}}

	local rp = {} -- Rotated points storage.

  -- The scale is mw (map width) * 4 * scale. 
  -- Mapwidth is * 4 because we actually want HALF width to center the image.
  local scalex = (mw<<2) * scale
  local scaley = (mh<<2) * scale
  -- Rotate the quad points.
  for p=1,#sv do 
    -- Apply scaling.
    local _sx = sv[p][1] * scalex 
		local _sy = sv[p][2] * scaley
    -- Apply rotations.
		local a = angle
		local rx = _sx * math.cos(a) - _sy * math.sin(a)
		local ry = _sx * math.sin(a) + _sy * math.cos(a)
    -- Apply transformations.
    sv[p][1] = rx + sx
    sv[p][2] = ry + sy
    -- Scale UV's.
    sv[p][3] = (mx<<3) + (sv[p][3] * (mw<<3))
    sv[p][4] = (my<<3) + (sv[p][4] * (mh<<3))
  end
  -- Draw two triangles for the quad.
  textri( sv[1][1],sv[1][2], -- Do I want to explain this? Yes. Do I understand this? No. Is it necessary? Apparently so or else it wouldn't be here (sarcasm moment).
          sv[1][1],sv[2][2],
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

-- But why? Why would you do that? Why would you do any of that? - JonTron | originally called Makeplanet(), bro (MagicMan(?)) was not playing with a full deck of cards.
-- This function for some reason draws a planet with multiple sprites in a line, AKA, a rectangle is conformed to the size of a triangle and put together with other triangles like a slice of pie
--to make it look like a circle. The radius, if defined with pretty much any value other than like a few ones that I found, will leave a large gap in the slices of the pie, which in this case
--is Galactus' grandma's favorite BULLSH*T PIE. We need sprite planets as well, or they can be generated with code, I don't care, I just want planets looking like spherical planets and not
--whatever the hell this weird 2D sliced up poor planet is.
function makePlanet(x,y,radius,sides,UVx,UVy,UVw,UVh)

  local angletemp = math.rad(360//sides)
  local angle = angletemp

  local lx = radius * math.cos(angletemp) + radius
  local ly = radius * math.sin(angletemp) + radius
  local rx = radius * math.cos(angletemp+angletemp) + radius
  local ry = radius * math.sin(angletemp+angletemp) + radius


  --...What? Bro is not cooking.
  --8,0 -> 16,8

  local planet = {} -- Stores the necessary ttri() values.

  for e = 1,sides do
    local ax = x + radius + (lx-radius)*math.cos(angle)-(ly-radius)*math.sin(angle)
    local ay = y + radius + (lx-radius)*math.sin(angle)+(ly-radius)*math.cos(angle)
    local aax = x + radius + (rx-radius)*math.cos(angle)-(ry-radius)*math.sin(angle)
    local aay = y + radius + (rx-radius)*math.sin(angle)+(ry-radius)*math.cos(angle)
    table.insert(planet, {ax, ay, aax, aay, radius+x, radius+y, UVx+UVw, UVy, UVx, UVy, UVx+UVw, UVy+UVh}) -- Cheeky little table.insert() which is almost completely unnecessary.
    angle = angle+angletemp
  end
  
  for _,val in pairs(planet) do -- I still don't personally understand why _,val works, but honestly I'll just learn tomorrow, I gotta study.. (this comment was written 6 minutes after the philosophical question comment was).
    ttri(table.unpack(val))
   end
    
end


-- init() is goofy. End of story.
-- Honestly if we used functions to define certain entities instead of stupid lists, that would be.. probably not a good idea. Let's try the metatables first.
function init()
  -- Time :) again. *init* stupid? Ha, ha.. ha.
  t=t+1

  -- p = player.
  p={x=116,y=64,spr=258,ax=0.3,ay=0.3,vx=0,vy=0,dx=0.8,dy=0.8}

  -- f = temporary fire behind ship. BUG: FIRE LAGS BEHIND SHIP AS IT SLOWS DOWN.
  f={x=p.x,y=p.y + 16,sprf=290}

  -- cam = camera, default set to middle of the screen. Will work on lerped and rotated player-following-camera tomorrow, I must study for philosophy exam. Speaking of,
  --I have a philosophical question: if I'm awake at 1:30 AM and I have an exam I'm supposed to be studying for, do I study or keep doing this? (spoilers: I keep doing this).
  cam={x=120,y=68}

  -- rot = rotation for the sprite; I know I know, get off my ass. It's terrible, and I'll get to ttri() rotations along with the camera stuff mentioned before.
  rot=0

  -- speed = the speed variable MagicMan(?)'s previous game was missing because he was too lazy to actually add one, instead, opted to just constantly repeatedly type the same value
  --over and over again for the same reason. Shaking my head. Is by default set to 4.5, but it will vary depending on what stuff we decide to do with it in the future.
  speed=4.5
end

-- Described in TIC() function because hehe.
function velocity()

  -- Leaving this here so I can implement gravity for the character later.

  --if math.abs(p.vy) > (speed) then
  --  if p.vy < 0 then p.vy = (speed) else p.vy = (speed) end
  --end

  -- Basic code that was mimicked from the velocity function in my old game (magic's old code which is kinda bad but it's okay for now).

  -- I'm not.. particularly sure why we're putting the velocity values in parenthesis, but hey, I don't really care, it's just parenthesis.
  p.x = p.x + (p.vx) -- Temporary ship's x position = Temporary ship's x position PLUS (parenthesis for some reason) Temporary ship's velocity in the x direction.
  p.y = p.y + (p.vy) -- Temporary ship's y position = Temporary ship's y position PLUS (parenthesis for some reason) Temporary ship's velocity in the y direction.

  p.vx= p.vx*p.dx -- Temporary ship's velocity in the x direction = Temporary ship's velocity in the x direction TIMES Temporary ship's deccelaration in the x direction.
  p.vy = p.vy*p.dy -- Temporary ship's velocity in the y direction = Temporary ship's velocity in the y direction TIMES Temporary ship's deccelaration in the y direction.
  if math.abs(p.vx) < (0.05) then p.vx = 0 end -- If the absolute value of the temporary ship's velocity in the x direction IS LESS THAN 
  --(parenthesis for some reason) 0.05 then temporary ship's velocity in the x direction = 0.
  if math.abs(p.vy) < (0.05) then p.vy = 0 end -- If the absolute value of the temporary ship's velocity in the y direction IS LESS THAN 
  --(parenthesis for some reason) 0.05 then temporary ship's velocity in the y direction = 0.
end


-- Goofy ahh movement script, described in the TIC() function because, ofc, hehe.
function flyShipAndMove()

  -- This is pretty much just basic movement code for a ship with accel and deccel. Can be applied to other
  --moving objects/entities/the player.

  -- Press A or Left Arrow to move to the left. Crazy, I know.
  if btn(2) or key(01) then
    if p.vx > -speed then
      p.vx = p.vx - (p.ax) -- Again, the motherf**king parenthesis. WHY??
      f.x = p.x + 16
      f.y = p.y
      rot = 3
    end
  end

  -- Press D or Right Arrow to move to the right. Nuts, I'm aware.
  if btn(3) or key(04) then
    if p.vx < speed then
      p.vx = p.vx + (p.ax)
      f.x = p.x - 16
      f.y = p.y
      rot = 1
    end
  end

  -- Press W or Up Arrow to move to up/forward. Insane, I understand.
  if btn(0) or key(23) then
    if p.vy > -speed then
      p.vy = p.vy - (p.ay)
      f.y = p.y + 16
      f.x = p.x
      rot = 0
    end
  end

  -- Press S or Bottom Arrow to move down/backward. Crikey, I gets it.
  if btn(1) or key(19) then
    if p.vy < speed then
      p.vy = p.vy + (p.ay)
      f.y = p.y - 16
      f.x = p.x
      rot = 2
    end
  end
end

-- Goofy ahh draw() function because sorting.
function draw()
  -- I wanna sort everything that needs to be drawn into this function
  --because it just makes sorting easier, especially if there are bugs.
  --DO NOT add redundant calls, especially with different names. No functions like
  --function draw(sprite) <and then use sprite here like an idiot> end
  --if we're gonna make it general like that, might as well just code this in Brainf**k.

  -- Calls the makePlanet() function to draw the *walkable* planet with ttri(). Idea: instead of constantly using this (although we totally could to do completely circular worlds), 
  --just set the map to whichever side you're on so it *looks* like you're going around the planet. Also, atmospheric effects will be necessary as well as parallax shifting.

  makePlanet(circlex,circley,circleradius,circlesides,8,0,8,32)

  -- Draws the flames from behind the temporary ship
  spr(f.sprf,(f.x-8)-cam.x,(f.y-8)-cam.y, 0, 1, 0 , rot, 2, 2)

  -- Draws the sprite for said temporary ship, is centered as well.
  spr(p.spr,(p.x-8)-cam.x,(p.y-8)-cam.y, 0, 1, 0 , rot, 2, 2)

  -- Draws the sprite for the mouse cursor.
  spr(4,gmouse().x,gmouse().y,0,1)
end

init() -- Honestly stuff breaks if I don't have this here.

-- TIC-80 moment.
function TIC()

    -- Time function.
    t=t+1

    -- Temporary camera stuff.
    cam.x=120-p.x
    cam.y=68-p.y

    -- Calls movement function, called flyShipAndMove() for now as that's what it's doing.
    flyShipAndMove()

    -- Refer to velocity() function comments.
    velocity()

    -- There were a lot of issues getting this shit to work properly, for instance, when I fixed it, the poke was the wrong
    --type of poke; e.g., "poke4(0x03FF8, 0)" when it should just be poke(). Plus, it was placed *after* the vbank(1) selection call,
    --therefore nullifying whatever it was trying to do in the first place due to the fact that vbank(1) doesn't use the 0x03FF8 memory address like vbank(0) does (spoilers: it's for transparency).
    -- Adding onto this, the cls() was incorrectly set, and wasn't clearing the screen after vbank(1), instead, clearing it after vbank(0), making the screen the color of vbank(1)'s palette, 
    --which is undesirable. My fixes definitely are temporary as how it looks as of this moment is really strange, but I will organize in moments with comments :p.

    -- Set the vbank to 0 for the background.
    vbank(0)

    -- Set the border radius to the color value of the 13th color slot.
    poke(0x3FF8, 13)

    -- Clears the screen with the color value of the 4th color slot.
    cls(4)

    -- Set the vbank to 1 for the foreground; e.g., player, tiles, etc. and the like.
    vbank(1)

    -- Sets the mouse cursor to be the sprite in #4 of the sprite sheet.
    poke(0x03FFB, 4)

    -- Sets the transparency color for vbank(1).
    poke(0x3FF8, 0)

    -- Clears the screen with the color value of slot 0.
    cls(0)

    -- Calls the draw function I created, it's done in the foreground after the clear screen of vbank(1), as to divide from the functions and important memory stuff.
    draw()

    -- Testing, draws the values of the temporary ship's position on screen: warning, uses fixed point numbers because it's goofy.
    print(p.x, 32, 32)
    print(p.y, 32, 40)
    print("x: ", 20, 32)
    print("y: ", 20, 40)

    -- Exit the current game to console with "`"
    if key(44) then
      exit()
    end
end

-- Mouse function ripped directly from my old game (magic's old code that *doesn't* suck, haha).
function gmouse()
	local m = {}
	m.x,m.y,m.left,m.middle,m.right,m.scrollx,m.scrolly = mouse()
	return m
end

-- I hate that this is here (the <TILES> and whatever's below it).

-- <TILES>
-- 001:4444444444444444a44aa44aa4aaa4aaaaaaaa2aa22aa2222222aa22aaa22a22
-- 002:0000055500005555000222550002225500022259000222590222555b0222555b
-- 003:55555000555555505555552022222220999999001199110011bb1100bbbbbb00
-- 004:0000000000059000000000000202505005029020000000000009500000000000
-- 016:5558855555888855555885555558855555588555555885555558855555588555
-- 017:2222aaaa2aa22a22aaaa222aaaa222aaa222a2aa22aaa22a2aaaaa222aaaaaa2
-- 018:022225550222bbb80000bbee00000bee00000111000001110000311100003330
-- 019:bbbbb00088880000448800004444bb004444ee00011100000133000000330000
-- 033:abaaaaaabaaaabaabaabaabababbaabbbbbbbbbbbbbbbbbbeeeeeeeeeeeeeeee
-- 034:0000000000000fff000eeeee00eeebbb00bbbbbb0eeeeeee0bbbbbbb022aaaab
-- 035:00000000fff00000eeeee000bbbeee00bbbbbb00eeeeeee0ebbbbbe0bb222bb0
-- 049:eeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffffffffffff
-- 050:0aaaaa220bbbbbbb0eeeeeee00bbbbbb00bbbbbb000beeee00000fff00000000
-- 051:2223aaa0bbaaabb0ebbbbbe0eeeeee00bbbbbb00eeeeb000fff0000000000000
-- 224:000000000000000000000000000000009999999999888999ded444d44d444ded
-- </TILES>

-- <SPRITES>
-- 000:0000055500005555000222550002225500022259000222590222555b0222555b
-- 001:55555000555555505555552022222220999999001199110011bb1100bbbbbb00
-- 002:000000050000005f0000002c0000002c0c000326060023230300232502522325
-- 003:50000000f5000000c2000000c2000000623000c0323200605232003052322520
-- 016:022225550222bbb80000bbee00000bee00000111000001110000311100003330
-- 017:bbbbb00088880000448800004444bb004444ee00011100000133000000330000
-- 018:05523322255231232522332002522300252220012552001f2033003c006c0003
-- 019:223325503213255202332252003225201002225261002552630033023000c600
-- 032:122244ddaa444ddd24444dd044488ddd244488d8aa4448d8122448d8112488dd
-- 033:00dd88ddddd84ddd8d44d88d4844d8444448d844244884441444442412244232
-- 034:000000000000000c0000000f00000c00000000ff00c60000000f66660c00ffff
-- 035:00000000c0000000f000000000c00000ff00000000006c006666f000ffff00c0
-- 048:122a223312211233112111231121331331223333331211333111133131133331
-- 049:1121432111111331121131313333311311331111111333331111333311113333
-- 050:fc600000ff6666660ffccccc000fffff00000000000000000000000000000000
-- 051:000006cf666666ffcccccff0fffff00000000000000000000000000000000000
-- </SPRITES>

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

-- <PALETTE>
-- 000:d1b187c77b58ae5d4079444a4b3d44ba91589274414d453977743bb3a555d2c9a58caba14b726e574852847875ab9b8e
-- 001:0000001f0e1c8331293e2137216c4bdc534b7664fed365c846af45e18d799a6348d6b97b9ec2e8a1d685e9d8a1f5f4eb
-- </PALETTE>

