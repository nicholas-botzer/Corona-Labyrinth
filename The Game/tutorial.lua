-----------------------------------------------------------------------------------------
--
-- tutorial.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
system.activate("multitouch")
local widget = require "widget"
local StickLib   = require("lib_analog_stick")
local physics = require("physics")
require('CreatureClass')
require('PlayerClass')
require('SpiderClass')
require('DemonClass')
local PerspectiveLib = require("perspective")
local track = require ("track")
tileSize = 64
floorsDone = -1
require("main") 
require("options")
require("ChestClass")

-- declarations
local rect, invBtn
local tempHealth = 100
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local swordBtn
local swordClashSound = audio.loadSound("swordClash.mp3")
local openChestSound = audio.loadSound("chestOpen.mp3")
local swordSwishSound = audio.loadSound("swordSwish.mp3")
local stairsSound = audio.loadSound("stairs.mp3")
local hurt1Sound = audio.loadSound("hurt1.mp3")
local hurt2Sound = audio.loadSound("hurt2.mp3")
local hurt3Sound = audio.loadSound("hurt3.mp3")
local hurt4Sound = audio.loadSound("hurt4.mp3")
local hurt5Sound = audio.loadSound("hurt5.mp3")
local background, wall, ground, mask

-- 'onRelease' event listener
local function onInvBtnRelease()
	-- go to inventory.lua scene
	composer.gotoScene( "inventory", {effect="fade", time=150} )
	return true	-- indicates successful touch
end

----------------------------
--This function is called when the scene is entered (in order to handle moving from the inventory screen back to level1.lua
--This function applies any items that were equipped while in the inventory screen (if any)
----------------------------
local function handleConsumption() --Inventory items take effect here 
	if(inUse["potion"]) then 
		rect.health = rect.health + inUse["potion"]
		if(rect.health > 100) then --Don't allow health to exceed 100
			rect.health = 100 
		end
		inUse["potion"] = 0    --Reset potion restoration counter
	end
	if(inUse["sword"] and inUse["sword"].new) then
		rect.damage = rect.baseDamage + inUse["sword"].modifier 
		inUse["sword"].new = false  --Item is no longer new, has been equipped 
	end
	if(inUse["armor"] and inUse["armor"].new) then
		rect.armor = rect.baseArmor + inUse["armor"].modifier
		inUse["armor"].new = false  --Item is no longer new, has been equipped 
	end
	if(inUse["boots"] and inUse["boots"].new) then
		rect.speed = rect.baseSpeed + inUse["boots"].modifier 
		inUse["boots"].new = false  --Item is no longer new, has been equipped 
	end
end

------------------------------------------
-- onSwordBtnRelease() 
-- checks to see if the player is in range to use stairs, hit enemies, and open chests
------------------------------------------
local function onSwordBtnRelease()
	-- change sprite and play audio
	rect:pickAnimation()
	rect.model:play()
	
	--Handle swinging at enemies here 
	--Test to see if any enemy is range of player character.
	monsterNum = 1
	while(monsterNum <= table.getn(creatures))do
		if( not creatures[monsterNum].isDead)then	--only do range detection if the enemy is alive
			if(math.abs(rect.model.x - creatures[monsterNum].model.x) < 40 and math.abs(rect.model.y - creatures[monsterNum].model.y) < 40) then	--check the distance between the player and the creature
				creatures[monsterNum]:takeDamage(rect.damage)
				knockbackCreature(rect, creatures[monsterNum], 500)
				audio.play( swordClashSound ) 
				--prompt the user to exit tutorial upon killing the enemy
				if (creatures[monsterNum].health <= 0) then
					prompt.text = "Continue to the stairs and press\n the attack button to end the tutorial"
				end--end if
			end--end if
		end
		monsterNum = monsterNum + 1
	end

	--Handle chest opening here  
	--check all chests and use a flag
	flag = false
	chestNum = 1
	while(not flag and chestNum <= table.getn(chests)) do
		if((math.abs(rect.model.x - chests[chestNum]:getX()) < 50) and (math.abs(rect.model.y - chests[chestNum]:getY()) < 50)) then
			if(chests[chestNum].closed == true) then 
				flag = true
				chests[chestNum]:open() 
				audio.play( openChestSound ) 
				table.insert(holding, chests[chestNum]:getContents()) 
				prompt.text = "Items retrieved from chests can be equipped \nby clicking on the inventory button(top right)"
				timer.performWithDelay(3000, function() prompt.text = "To fight a monster press the attack button\nwhen one is close by" end) 
			end--end if the chest is closed
		end--end checking if player is near chest
		chestNum = chestNum + 1
	end--end while
	
	--test to exit the tutorial
	if( not flag)then
		if(math.abs(rect.model.x - (stairs.x+50)) < 50 and math.abs(rect.model.y - (stairs.y+50)) < 50)then
			audio.play( stairsSound )
			composer.gotoScene( "menu", {effect="fade", time=500} )	
			composer.removeScene("tutorial")
			composer.removeScene("inventory")
		end
	end
	
	return true
end 

-------------------------------------------------------------------------------------
--Following functions (determineWallPos() and determineDiagonal() determine where the wall is in 
--relation to the player sprite based on 8 collision rectangles that are constantly around the player 
-------------------------------------------------------------------------------------
local function determineWallPosition() 
	pos = "" 
	if(upRect.detected) then
		pos = pos.."u"
	end
	if(leftRect.detected) then
		pos = pos.."l"
	end
	if(rightRect.detected) then
		pos = pos.."r"
	end
	if(downRect.detected) then
		pos = pos.."d"
	end
	if(pos == "") then 
		pos = "noWall" 
	end
	return pos
end

local function detectDiagonal() 
	pos = "" 
	if(TRD.detected) then
		pos = pos.."TRD" 
	elseif(TLD.detected) then 
		pos = pos.."TLD"
	elseif(BLD.detected) then 
		pos = pos.."BLD"
	elseif(BRD.detected) then 
		pos = pos.."BRD"
	end
	return pos 
end

-----------------------------------------------------------------------------------------
--updateHealth decreases the health bar when the player takes damage
-----------------------------------------------------------------------------------------
local function updateHealth( event )
	healthAmount.text = rect.health .. "/" .. rect.maxHealth
	healthBar.width = rect.health * 1.2			--decreases the red in the health bar by 1% of its width
	healthBar.x = 10 - ((100 - rect.health) * .6)	--shifts the healthBar so it decreases from the right only
--calculation	= starting X - ((playerMaxHealth - playerCurrentHealth) * half of 1% of the healthBar.width)
	if(rect.health <= 0) then
		composer.gotoScene("death")
		composer.removeScene("inventory")
		composer.removeScene("tutorial") 
	end
end					

-----------------------------------------------------------------------------------------
--trackPlayer() cycles through the enemies having them each call the track function
-----------------------------------------------------------------------------------------
local function trackPlayer()
	for num=1,table.getn(creatures) do
		if (creatures[num].model and not creatures[num].isDead) then
			track.doFollow (creatures[num], rect, creatures[num].speed)
		end
	end
end	

-----------------------------------------------------------------------------------------
--knockbackCreature(attacker, creature, force) 
--		calculates the X and Y axis knockback for a creature or player
--		*knockback movement is handled in track.lua for creatures and lib_analog_stick.lua for the player
-----------------------------------------------------------------------------------------
function knockbackCreature(attacker, creature, force)
	local distanceX = creature.model.x - attacker.model.x;
	local distanceY = creature.model.y - attacker.model.y;
	local totalDistance = math.sqrt ( ( distanceX * distanceX ) + ( distanceY * distanceY ) )
	local moveDistX = distanceX / totalDistance;
	local moveDistY = distanceY / totalDistance;
	
	--set the knockback values for the creature
	creature.knockbackX = force * moveDistX /totalDistance
	creature.knockbackY = force * moveDistY /totalDistance
end

-----------------------------------------------------------------------------------------
--attackPlayer(monster) - tests whether a creature is in range to hit the player
--		*attackPlayer also knocks the CREATURE back
-----------------------------------------------------------------------------------------
function attackPlayer(monster)
	if (math.abs(monster.model.x - rect.model.x) < 25 and math.abs(monster.model.y - rect.model.y) < 25) then	--test if in range
		rect:takeDamage(monster.damage)
		knockbackCreature(monster, rect, 300)
		dmgMask.isVisible = true;
		local rand = math.random(1,5)
		if (rand == 1) then audio.play(hurt1Sound)
		elseif (rand == 2) then audio.play(hurt2Sound)
		elseif (rand == 3) then audio.play(hurt3Sound)
		elseif (rand == 4) then audio.play(hurt4Sound)
		elseif (rand == 5) then audio.play(hurt5Sound)
		end
	end
end
					
--Creates the rooms tiles for the map that is generated.
local function makeRoom(r,c)

    room = display.newImageRect("floors.png",tileSize,tileSize)
	room.anchorX, room.anchorY = 0, 0
    room.x,room.y = r*tileSize,c*tileSize
	
	return room
end
--Creates the wall tiles for the map and adds the physics to them for collision handling
local function makeWall(r,c)
    wall = display.newImageRect("walls.png",tileSize,tileSize)
	wall.anchorX, wall.anchorY = 0, 0
    wall.x,wall.y = r*tileSize,c*tileSize
	physics.addBody(wall,"static",{})
	
	return wall
end
--Creates the stairs that allow the user to exit the tutorial
function makeStairs(r,c)
	stairs = display.newImageRect("stairs.png",100,100)
	stairs.anchorX, stairs.anchorY = 0, 0
	stairs.x,stairs.y = (r*tileSize)-50,(c*tileSize)-50
	
	return stairs
end

local function generateBossRoom(rows,cols)
	for i=0,rows do
		for j=0,cols do
			if(bossRoom[j][i] == 1)then
				room = makeRoom(i,j)
				g1:insert(room)
			elseif(bossRoom[j][i] == 3 or bossRoom[j][i] == 9)then
				wall = makeWall(i,j)
				g1:insert(wall)
			end
		end
	end
	for i=1,6 do
		for j=4,5 do
			wall = makeWall(i,j)
			g1:insert(wall)
		end
	end
	stairs = makeStairs(2,2)
	g1:insert( stairs )
end

local function main( event )
	analogStick:slide(rect,-rect.speed)
	if(prompt) then 
		prompt.x = rect.model.x-110
		prompt.y = rect.model.y-70
	end
	if(not tutorialFixed) then
		tutorialFixed = true
		rect.health = 100 
	end
	
	--Remove the damage mask after 25ms if it is currently visible--
	if (dmgMask.isVisible) then
		timer.performWithDelay (25, function() dmgMask.isVisible = false end)
	end
	
	angle = analogStick:getAngle() 
	moving = analogStick:getMoving()
	
	--Determine which animation to play based on the direction of the analog stick	
	if(angle <= 45 or angle > 315) then
		seq = "forward"
	elseif(angle <= 135 and angle > 45) then
		seq = "right"
	elseif(angle <= 225 and angle > 135) then 
		seq = "back" 
	elseif(angle <= 315 and angle > 225) then 
		seq = "left" 
	end
	
	--Change the sequence only if another sequence isn't still playing 
	if(not (seq == rect.model.sequence) and moving) then -- and not attacking
		rect.model:setSequence(seq)
	end
	
	--If the analog stick is moving, animate the sprite
	if(moving) then 
		rect.model:play() 
	end
end
-----------------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless composer.removeScene() is called.
--
-----------------------------------------------------------------------------------------

function scene:create (event)
	local group = self.view

	tempHealth = 100 -- will set the players health back to 100 when entering the tutorial

	chests = {} --holds all of the chests that will be spawned onto the map
	creatures = {} --holds all of the monsters that get spawn onto the map
	monsterGroup = display.newGroup()
	camera=PerspectiveLib.createView() --creates the camera that will track the player for us
	physics.start()     --generates the starting physics for the game
	physics.setGravity(0,0)
	--mask that limits the player vision slightly, the mask also turns red briefly upon taking damage
	mask = display.newImageRect( "masked3.png", screenW, screenH )
	mask.anchorX, mask.anchorY = 0, 0
	mask.x, mask.y = 0, 0
	--red mask that shows up when the user takes damage
	dmgMask = display.newImageRect( "masked3_dmg.png", screenW, screenH )
	dmgMask.anchorX, dmgMask.anchorY = 0, 0
	dmgMask.x, dmgMask.y = 0, 0
	dmgMask.isVisible = false
	
	--g1 is the display group for the map that the user will be placed into
	g1 = display.newGroup()
	bossRoom = {}
	for x=0,9 do
		bossRoom[x] = {}
		for y=0,9 do
			if(x == 0 or x == 9)then
				bossRoom[x][y] = 9
			elseif(y == 0 or y == 9)then
				bossRoom[x][y] = 9
			else
				bossRoom[x][y] = 1
			end -- end if
		end -- end for y
	end--end for x
	generateBossRoom(9,9)
	startRow = 2
	startCol = 8
	
	chest = Chest.new(3.5 * tileSize, 7 * tileSize)
	table.insert(chests,chest)
	g1:insert(chest.pic)
	creature = Creature((7*tileSize),(2*tileSize))
	table.insert(creatures,creature)
	monsterGroup:insert(creature.model)
	

	--generate the health bar for the player
	healthBackground = display.newRect(10,10,120,15) 
	healthBackground.anchorX, healthBackground.anchorY = 0, 0
    healthBackground.strokeWidth = 3
    healthBackground:setFillColor(0,0,0)
    healthBackground:setStrokeColor(255,255,255)
    
    healthBar = display.newRect(10,10,120,15)
	healthBar.anchorX, healthBar.anchorY = 0, 0
    healthBar:setFillColor(180,0,0)
    healthBar.x = 10
    healthBar.y = 10
    
    healthAmount = display.newText("", 70, 7, native.systemFont, 18)
	
	-- add an inventory button
	invBtn = widget.newButton{
		label="Inventory",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=140, height=30,
		onRelease = onInvBtnRelease	-- event listener function
	}
	invBtn.x = screenW - invBtn.width * .5
	invBtn.y = invBtn.height * .5
	
	--add a swordBtn
	swordBtn = widget.newButton{
		label="Attack",
		labelColor = {default = {255}, over = {128} },
		defaultFile="swordIcon.png",
		overFile="swordIcon.png",
		width = 58, height = 65,
		onRelease = onSwordBtnRelease
	}
	swordBtn.x = screenW - swordBtn.width*.5 
	swordBtn.y = screenH - swordBtn.height 
	
	-- adds an analog stick
	analogStick = StickLib.NewStick(
		{
			x = screenW * .17,
			y = screenH * .75,
			thumbSize = 50,
			borderSize = 55,
			snapBackSpeed = .35,
			R = 255,
			G = 255,
			B = 255
		} 
	)

	--Declare Sprite Object 
	rect = Player(startRow * tileSize, startCol * tileSize)
	rect.health = tempHealth
	physics.addBody(rect.model, "dynamic", {})
	rect.model.isFixedRotation = true
	
	-- Tutorial prompts to help the player
	prompt = display.newText("Move the analog stick to control character", rect.model.x-110, rect.model.y-70, native.systemFontBold, 15) 
	timer.performWithDelay(3000, function() prompt.text = "To open a chest stand in front of it \nand press attack" end) 
	prompt.anchorX, prompt.anchorY = 0, 0
		
	-- all display objects must be inserted into group in layer order 
	group:insert(g1)
	group:insert(monsterGroup)
	group:insert( rect.model )	
	
	--camera set up
	--groups get inserted in the appropriate order with the map aka g1 being the first thing inserted
	--all of the monsters are then inserted on top of the map, followed by the character
	camera:add(g1,4,true)
	camera:add(monsterGroup,3,true)
	camera:add(rect.model, 2, true)
	camera:setFocus(rect.model)
	camera:setBounds(false)
	camera:track()
	group:insert( camera )
	group:insert( mask )
	group:insert( dmgMask )
	group:insert( analogStick )
	group:insert( invBtn )
	group:insert( swordBtn )
	group:insert(healthBackground)
	group:insert(healthBar)
	group:insert(healthAmount)
	g1:insert(prompt)
	
	Runtime:addEventListener( "enterFrame", main )
	Runtime:addEventListener( "enterFrame", updateHealth )
	Runtime:addEventListener( "enterFrame", trackPlayer)
end

-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view
	--creates the eventListeners that are needed to handle different functions
	Runtime:addEventListener( "enterFrame", main )
	Runtime:addEventListener( "enterFrame", updateHealth ) 	--listens for changing health
	Runtime:addEventListener( "enterFrame", trackPlayer) 	--makes the enimies track the player
	composer.returnTo = "menu" 
	handleConsumption() 		--Determine if any items were placed onto the player/potions used
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	--Removes all of the eventListeners because the scene has changed and they need destroyed
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
	tempHealth = rect.health
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	--Removes all of the eventListeners because the scene has changed and they need destroyed
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
	
	--make sure we remove things we have added
	if invBtn then
		invBtn:removeSelf()
		invBtn = nil
	end
	if camera then
		camera:destroy()
		camera = nil
	end
	if analogStick then
		analogStick:delete()
		analogStick = nil
	end
	if prompt then 
		g1:remove(prompt) 
		prompt = nil
	end
	display.remove(g1)
	composer.removeScene("inventory")
	
end




-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene
