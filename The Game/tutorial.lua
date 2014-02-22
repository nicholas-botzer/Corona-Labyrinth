-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
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
floorsDone = 0
require("main") 
require("options")
require("ChestClass")

-- declarations
local rect, invBtn
local tempHealth = 100
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local swordBtn
local swordClashSound = audio.loadSound("Sword clash sound effect.mp3")
local background, wall, ground, mask

-- 'onRelease' event listener
local function onInvBtnRelease()
	-- go to inventory.lua scene
	storyboard.gotoScene( "inventory", "fade", 150 )
	return true	-- indicates successful touch
end

local function handleConsumption() --Inventory items take effect here 
	if(inUse["potion"]) then 
		rect.health = rect.health + inUse["potion"]
		if(rect.health > 100) then 
			rect.health = 100 
		end
	end
	if(inUse["sword"] and inUse["sword"].new) then
		rect.damage = rect.baseDamage + inUse["sword"].modifier 
	end
	if(inUse["armor"] and inUse["armor"].new) then
		rect.armor = rect.baseArmor + inUse["armor"].modifier
	end
	if(inUse["boots"] and inUse["boots"].new) then
		rect.speed = rect.baseSpeed + inUse["boots"].modifier 
	end
end

local function onSwordBtnRelease()
	rect:pickAnimation()
	rect.model:play()
	audio.play( swordClashSound ) 
	
	--Handle swinging at enemies here 
	--Test to see if enemy is range of player character.
	monsterNum = 1
	while(monsterNum <= table.getn(creatures))do
		if( not creatures[monsterNum].isDead)then
			if(math.abs(rect.model.x - creatures[monsterNum].model.x) < 40 and math.abs(rect.model.y - creatures[monsterNum].model.y) < 40) then
				creatures[monsterNum]:takeDamage(rect.damage)
				knockbackCreature(rect, creatures[monsterNum], 500)
			
				--Remove enemy if 0 HP or lower
				if (creatures[monsterNum].health <= 0) then
					creatures[monsterNum].isDead = true
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
				local treasure = display.newText("You found a "..chests[chestNum]:getContents(), rect.model.x-65, rect.model.y-30, native.systemFontBold, 20) 
				table.insert(holding, chests[chestNum]:getContents()) 
				g1:insert(treasure) 
				timer.performWithDelay(1250, function() g1:remove(treasure) treasure = nil end)
			end--end if the chest is closed
		end--end checking if player is near chest
		chestNum = chestNum + 1
	end--end while
	
	if( not flag)then
		if(math.abs(rect.model.x - (stairs.x+50)) < 50 and math.abs(rect.model.y - (stairs.y+50)) < 50)then
			storyboard.gotoScene( "menu", "fade", 500 )	
			storyboard.purgeScene("tutorial")
			storyboard.purgeScene("inventory")
		end
	end
	
	return true
end 

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

local function onCollision( event )
	if(not event.object2.id) then  
		if ( event.phase == "began" ) then
			rect:takeDamage(2)
			dmgMask.isVisible = true;
			if(not analogStick:inCollision()) then
				rect.markX = rect.model.x 
				rect.markY = rect.model.y
			end
			wallPos = determineWallPosition()
			if(wallPos == "noWall") then
				wallPos = detectDiagonal()
			end
			print(wallPos)
			analogStick:collided(true, event.object1.x, event.object1.y, wallPos)
		end
	else 
		if (event.phase == "began") then 
			event.object2.count = 0 
			event.object2.detected = true
			event.object2.markX = event.object2.x 
			event.object2.markY = event.object2.y 
		elseif(event.phase == "ended") then   
			event.object2.count = event.object2.count + 1
			if(event.object2 == upRect) then 	
				if(event.object2.y > upRect.markY) then
					print("clearing top collision")
					upRect.detected = false
				end
			end
			if(event.object2 == leftRect) then 	
				if(event.object2.x > leftRect.markX) then
					print("clearing left collision")
					leftRect.detected = false
				end
			end
			if(event.object2 == rightRect) then 	
				if(event.object2.x < rightRect.markX) then
					print("clearing right collision")
					rightRect.detected = false
				end
			end
			if(event.object2 == downRect) then 	
				if(event.object2.y < downRect.markY) then
					print("clearing bottom collision")
					downRect.detected = false
				end
			end
			if(event.object2 == TRD) then 
				TRD.detected = false
				print("clearing top-right diagonal")
			end
			if(event.object2 == TLD) then 
				TLD.detected = false 
				print("clearing top-left diagonal")
			end
			if(event.object2 == BRD) then 
				BRD.detected = false
				print("clearing bottom-R diagonal")
			end
			if(event.object2 == BLD) then 
				BLD.detected = false
				print("clearing bottom-L diagonal")
			end
			if(event.object2.count >= 2) then
				print("Slid past") 
				analogStick:collided(false) 
				event.object2.detected = false 
			end
		end
	end
end

local function updateHealth( event )
	healthAmount.text = rect.health .. "/" .. rect.maxHealth
	healthBar.width = rect.health * 1.2			--decreases the red in the health bar by 1% of its width
	healthBar.x = 10 - ((100 - rect.health) * .6)	--shifts the healthBar so it decreases from the right only
	if(rect.health <= 0) then
		storyboard.gotoScene("death")
		storyboard.purgeScene("inventory")
		storyboard.purgeScene("tutorial") 
	end
end					
								-- = starting X - ((playerMaxHealth - playerCurrentHealth) * half of 1% of the healthBar.width)
					
local function trackPlayer()
	for num=1,table.getn(creatures) do
		if (creatures[num].model) then
			track.doFollow (creatures[num], rect, creatures[num].speed)
		end
	end
end	

function knockbackCreature(attacker, creature, force)
	local distanceX = creature.model.x - attacker.model.x;
	local distanceY = creature.model.y - attacker.model.y;
	local totalDistance = math.sqrt ( ( distanceX * distanceX ) + ( distanceY * distanceY ) )
	local moveDistX = distanceX / totalDistance;
	local moveDistY = distanceY / totalDistance;
	creature.knockbackX = force * moveDistX /totalDistance
	creature.knockbackY = force * moveDistY /totalDistance
end

function attackPlayer(monster)
	if (math.abs(monster.model.x - rect.model.x) < 20 and math.abs(monster.model.y - rect.model.y) < 25) then
		rect:takeDamage(monster.damage)
		knockbackCreature(rect, monster, 300)
		dmgMask.isVisible = true;
	end
end
					

local function makeRoom(r,c)
    room = display.newImageRect("floors.png",tileSize,tileSize)
    room:setReferencePoint(display.TopLeftReferencePoint)
    room.x,room.y = r*tileSize,c*tileSize
	
	return room
end
local function makeWall(r,c)
    wall = display.newImageRect("walls.png",tileSize,tileSize)
    wall:setReferencePoint(display.TopLeftReferencePoint)
    wall.x,wall.y = r*tileSize,c*tileSize
	physics.addBody(wall,"static",{})
	
	return wall
end
function makeStairs(r,c)
	stairs = display.newImageRect("stairs.png",100,100)
	stairs:setReferencePoint(display.TopLeftReferencePoint)
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
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------

function scene:createScene (event)
	local group = self.view
	if (tempHealth <= 0) then
		tempHealth = 100
	end
	chests = {}
	creatures = {}
	monsterGroup = display.newGroup()
	camera=PerspectiveLib.createView()
	physics.start()
	physics.setGravity(0,0)
	
	mask = display.newImageRect( "masked3.png", screenW, screenH )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0
	
	dmgMask = display.newImageRect( "masked3_dmg.png", screenW, screenH )
	dmgMask:setReferencePoint( display.TopLeftReferencePoint )
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
    healthBackground:setReferencePoint(display.TopLeftReferencePoint) 
    healthBackground.strokeWidth = 3
    healthBackground:setFillColor(0,0,0)
    healthBackground:setStrokeColor(255,255,255)
    
    healthBar = display.newRect(10,10,120,15)
    healthBar:setReferencePoint(display.TopLeftReferencePoint)
    healthBar:setFillColor(180,0,0)
    healthBar.x = 10
    healthBar.y = 10
    
    healthAmount = display.newText {
    	text = "100/100", --defualt value, gets overwritten in updateHealth()
    	x = 70,
    	y = 17
    }
	
	-- add an inventory button
	invBtn = widget.newButton{
		label="Inventory",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=140, height=30,
		onRelease = onInvBtnRelease	-- event listener function
	}
	invBtn:setReferencePoint( display.CenterReferencePoint )
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
	swordBtn:setReferencePoint( display.CenterReferencePoint )
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
	rect.model.isSensor = true
	
	upRect = display.newRect(rect.model.x , rect.model.y, 20,40)
	upRect:setReferencePoint(display.BottomCenterReferencePoint)
	upRect.x = rect.model.x 
	upRect.y = rect.model.y
	upRect.id = "upRect"
	physics.addBody(upRect, "dynamic",{}) 
	upRect.isSensor = true
	upRect.isVisible = false
	
	downRect = display.newRect(rect.model.x , rect.model.y, 20,40)
	downRect:setReferencePoint(display.TopCenterReferencePoint)
	downRect.x = rect.model.x 
	downRect.y = rect.model.y
	downRect.id = "downRect"
	physics.addBody(downRect, "dynamic",{}) 
	downRect.isSensor = true
	downRect.isVisible = false
	
	rightRect = display.newRect(rect.model.x , rect.model.y, 40,20)
	rightRect:setReferencePoint(display.CenterLeftReferencePoint)
	rightRect.x = rect.model.x 
	rightRect.y = rect.model.y
	rightRect.id = "rightRect"
	physics.addBody(rightRect, "dynamic",{}) 
	rightRect.isSensor = true
	rightRect.isVisible = false
	
	leftRect = display.newRect(rect.model.x , rect.model.y, 40,20)
	leftRect:setReferencePoint(display.CenterRightReferencePoint)
	leftRect.x = rect.model.x 
	leftRect.y = rect.model.y
	leftRect.id = "leftRect"
	physics.addBody(leftRect, "dynamic",{}) 
	leftRect.isSensor = true
	leftRect.isVisible = false
	
	TRD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	TRD:setReferencePoint(display.BottomCenterReferencePoint)
	TRD.x = rect.model.x + rect.model.width*.5
	TRD.y = rect.model.y - rect.model.height*.1
	TRD.id = "TRD"
	physics.addBody(TRD, "dynamic",{}) 
	TRD.isSensor = true
	TRD.isVisible = false
	
	TLD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	TLD:setReferencePoint(display.BottomCenterReferencePoint)
	TLD.x = rect.model.x - rect.model.width*.5
	TLD.y = rect.model.y - rect.model.height*.1
	TLD.id = "TLD"
	physics.addBody(TLD, "dynamic",{}) 
	TLD.isSensor = true
	TLD.isVisible = false
	
	BLD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	BLD:setReferencePoint(display.TopCenterReferencePoint)
	BLD.x = rect.model.x - rect.model.width*.5
	BLD.y = rect.model.y + rect.model.height*.1
	BLD.id = "BLD"
	physics.addBody(BLD, "dynamic",{}) 
	BLD.isSensor = true
	BLD.isVisible = false

	BRD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	BRD:setReferencePoint(display.TopCenterReferencePoint)
	BRD.x = rect.model.x + rect.model.width*.5
	BRD.y = rect.model.y + rect.model.height*.1
	BRD.id = "BRD"
	physics.addBody(BRD, "dynamic",{}) 
	BRD.isSensor = true
	BRD.isVisible = false
	
	-- all display objects must be inserted into group in layer order 
	group:insert(g1)
	group:insert(monsterGroup)
	group:insert( rect.model )
	
	
	--camera set up
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
	
end

local function main( event )
	analogStick:slide(rect,-rect.speed, true)
	
	if(not tutorialFixed) then
		tutorialFixed = true
		rect.health = 100 
	end
	
	if (dmgMask.isVisible) then
		timer.performWithDelay (25, function() dmgMask.isVisible = false end)
	end
	
	upRect.x = rect.model.x 
	upRect.y = rect.model.y
	leftRect.x = rect.model.x 
	leftRect.y = rect.model.y
	downRect.x = rect.model.x 
	downRect.y = rect.model.y
	rightRect.x = rect.model.x 
	rightRect.y = rect.model.y
	TRD.x = rect.model.x + rect.model.width*.5
	TRD.y = rect.model.y - rect.model.height*.1
	TLD.x = rect.model.x - rect.model.width*.5
	TLD.y = rect.model.y - rect.model.height*.1
	BLD.x = rect.model.x - rect.model.width*.5
	BLD.y = rect.model.y + rect.model.height*.1
	BRD.x = rect.model.x + rect.model.width*.5
	BRD.y = rect.model.y + rect.model.height*.1

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

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	Runtime:addEventListener( "enterFrame", main )
	Runtime:addEventListener( "enterFrame", updateHealth )
	Runtime:addEventListener( "enterFrame", trackPlayer)
	Runtime:addEventListener( "collision", onCollision )
	storyboard.returnTo = "menu" 
	handleConsumption() 
	upRect.detected = false 
	downRect.detected = false 
	leftRect.detected = false 
	rightRect.detected = false 
	TLD.detected = false 
	TRD.detected = false 
	BLD.detected = false 
	BRD.detected = false  
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
	Runtime:removeEventListener( "collision", onCollision) 
	tempHealth = rect.health
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
	Runtime:removeEventListener( "collision", onCollision) 
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
	if treasure then
		g1:remove(treasure)
	end
	display.remove(g1)
	storyboard.purgeScene("inventory")
	
end




-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene
