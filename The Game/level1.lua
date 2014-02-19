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
require("RoomClass")

-- declarations
local rect, invBtn
local tempHealth = 100
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local swordBtn
local swordClashSound = audio.loadSound("Sword clash sound effect.mp3")
local background, wall, ground, mask
local labyrinthMusic = audio.loadStream("Battle Escape.mp3")
local bossMusic = audio.loadStream("battleThemeA.mp3")

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
		inUse["potion"] = 0 
	end
	if(inUse["sword"] and inUse["sword"].new) then
		rect.damage = rect.baseDamage + inUse["sword"].modifier 
		inUse["sword"].new = false 
	end
	if(inUse["armor"] and inUse["armor"].new) then
		rect.armor = rect.baseArmor + inUse["armor"].modifier
		inUse["armor"] = false 
	end
	if(inUse["boots"] and inUse["boots"].new) then
		rect.speed = rect.baseSpeed + inUse["boots"].modifier 
		inUse["boots"] = false 
	end
end

local function alreadyHolding(name) 
	containedFlag = false
	for i=1,table.getn(holding),1 do 
		if(holding[i] == name) then
			containedFlag = true
		end
	end
	return containedFlag 
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
				print (creatures[monsterNum].isDead)
			
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
				local treasure = display.newText("You found a "..chests[chestNum]:getContents(), rect.model.x-70, rect.model.y-40, native.systemFontBold, 20) 
				if(not alreadyHolding(chests[chestNum]:getContents()) or string.find(chests[chestNum]:getContents(), "potion")) then
					table.insert(holding, chests[chestNum]:getContents()) 
				end
				g1:insert(treasure) 
				timer.performWithDelay(1250, function() if (treasure) then g1:remove(treasure) treasure = nil end end)
			end--end if the chest is closed
		end--end checking if player is near chest
		chestNum = chestNum + 1
	end--end while
	
	if(floorsDone < levels and not flag)then
		if(math.abs(rect.model.x - (stairs.x+50)) < 50 and math.abs(rect.model.y - (stairs.y+50)) < 50)then
			floorsDone = floorsDone + 1
			tempHealth = rect.health
			storyboard.purgeScene("level1")
			storyboard.reloadScene("level1")
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
		storyboard.purgeScene("level1") 
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
		--knockbackCreature(monster, rect, 300)
	end
end
					
local function checkValidDir(r,c,botRow,botCol,dir)
	--subtract row 11 times making sure whole area is valid over 6 columns
	count = 0
	if(dir == 0)then
		local column = c - 5
		for i=1,12 do
			for j=1,9 do
				if(adjMatrix[column+j][r-i] == 9 or count > 10)then
					return false
				elseif(adjMatrix[column+j][r-i] == 1)then
					count = count + 1
				end
			end
		end
	elseif(dir == 1)then
		row = r - 5
		for i=1,9 do
			for j=1,12 do
				if(adjMatrix[botCol+j][row+i] == 9 or count > 10)then
					return false
				elseif(adjMatrix[botCol+j][row+i] == 1)then
					count = count + 1
				end
			end
		end
	elseif(dir == 2)then
		column = c - 5
		for i=1,9 do
			for j=1,12 do
				if(adjMatrix[column+j][botRow+i] == 9 or count > 10)then
					return false
				elseif(adjMatrix[column+j][botRow+i] == 1)then
					count = count + 1
				end
			end
		end	
	elseif(dir == 3)then
		row = r - 5
		for i=1,9 do
			for j=1,12 do
				if(adjMatrix[c-j][row+i] == 9 or count > 10)then
					return false
				elseif(adjMatrix[c-j][row+i] == 1)then
					count = count + 1
				end
			end
		end	
	end--end if for direction
	
	if(count > 10)then
		return false
	else
		return true
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
local function generateRoom(r,c,botRow,botCol,dir)
	
	width = math.random(3,5)
	height = math.random(3,5)
	if(dir == 0)then
		col = math.random((c+2)-width,c)
		row = r -1
		for i=0,height do
			for j=0,width do
			    adjMatrix[col + j][row - i] = 1
			end
		end
		currentRow = r - height
		currentCol = col
		currentBotRow = r - 1
		currentBotCol =  col + width
	elseif(dir == 1)then
		col = c + 1
		row = math.random((r-height + 1),r)
		for i=0,height do
			for j=0,width do
			    adjMatrix[col+j][row+i] = 1
			end
		end
		currentRow = row
		currentCol = col
		currentBotRow = row + height
		currentBotCol = col + width	
	elseif(dir == 2)then
		row = r + 1
		col = math.random((c+2)-width,c)
		for i=0,height do
			for j=0,width do
			    adjMatrix[col+j][row+i] = 1
			end
		end
		currentRow = row
		currentCol = col
		currentBotRow = row + height
		currentBotCol = col + width	
	elseif(dir == 3)then
		col = c + 1
		row = math.random(r,(r+height))
		for i=0,height do
			for j=0,width do
			    adjMatrix[col-j][row-i] = 1
			end
		end
		currentRow = row - height
		currentCol = col - width
		currentBotRow = row
		currentBotCol = col	
	end
	room = Room.new(currentRow,currentCol,currentBotRow,currentBotCol)
	table.insert(rooms,room)
end
local function generateEdge(r,c,botRow,botCol,dir)
	
	if(dir == 0 or dir == 2)then
		height = math.random(3,6)
		width = 2
		col = math.random(c,(botCol-1))
		for i=0,width do
			for j=0,height do
				if(dir == 0)then
					adjMatrix[col+i][r-j] = 1
				elseif(dir == 2)then
					adjMatrix[col+i][botRow+j] = 1
				end
			end
		end
		if(dir == 0)then
			currentRow = r - height
			currentBotRow = r - 1
			currentBotCol = col + 1
			currentCol = col
		elseif(dir == 2)then
			currentRow = botRow + height
			currentBotRow = botRow + 1
			currentBotCol = col + 1
			currentCol = col
		end
	--dir 1 goes downward and 3 goes upward
	elseif(dir == 1 or dir == 3)then
		height = 2
		width = math.random(3,6)
		row = math.random(r,(botRow-1))
		for i =0, height do
			for j=0, width do
				if(dir == 1)then
					adjMatrix[botCol+j][row+i] = 1
				elseif(dir == 3)then
					adjMatrix[c-j][row+i] = 1
				end
			end
		end
		if(dir == 1)then
			currentBotRow = row + 1
			currentRow = row
			currentCol = botCol + width
			currentBotCol = botCol
		elseif(dir == 3)then
			currentCol = c - width
			currentBotCol = c - 1
			currentBotRow = row + 1
			currentRow = row
		end
	end -- end outer if

end
local function generateStartRoom(r,c)

	for i=0,3 do
		for j=0,3 do
			adjMatrix[c+j][r+i] = 1
		end
	end
end
local function randomWalk(nodes)
--use the adj matrix and begin a random walk through the grid

	--check open locations in matrix
	currentRow = math.random(15,45)
	currentCol = math.random(15,45)
	startRow = currentRow + 1
	startCol = currentCol + 1
	currentBotRow = currentRow + 3
	currentBotCol = currentCol + 3
	generateStartRoom(currentRow,currentCol)
	nodesPlaced = 0
	flag = false
	while nodesPlaced < nodes do
		--create the room at the start location
		--chooseRandom location and check if it is valid
		--if it's valid go that direction and change adjMatrix
		--if not check a new direction
		rand = math.random(0,3)
		flag = false
		counter = 0
		while not flag and counter < 4 do
			if(rand == 0)then
				--check left
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,0)
				if(flag)then
					print("spawn left")
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,0)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,0)
				end
				counter = counter + 1
			--creates edge going down
			elseif(rand == 1)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,1)
				if(flag)then
					print("spawn down");
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,1)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,1)
				end
				counter = counter + 1
			--creates edge going to the right
			elseif(rand == 2)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,2)
				if(flag)then
					print("spawn right")
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,2)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,2)
				end
				counter = counter + 1
			--creates edge going up
			elseif(rand == 3)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,3)
				if(flag)then
					print("spawn up")
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,3)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,3)
				end
				counter = counter + 1
			end
			rand = rand + 1
			if(rand > 3)then
				rand = 0
			end
		end	--end inner while
		if(counter >= 4 and not flag)then
			adjMatrix[currentCol + 2][currentRow + 2] = 2
			adjMatrix[2][2] = 1
			nodesPlaced = 50
		else
			nodesPlaced = nodesPlaced + 1
		end
	end--end outer while signaling all nodes and edges have been placed
	adjMatrix[currentCol + 2][currentRow + 2] = 2

end
local function tunnels()
	
	numRooms = table.getn(rooms)
	for i=0,3 do
		randRoom = math.random(1,numRooms-1)
		rooms[randRoom]:connectRooms(rooms[math.random(1,numRooms-1)])
	end
end
local function generateMap(rows,cols)
	
	for i=0,rows do
		for j=0,cols do
			if(adjMatrix[j][i] == 1)then
				room = makeRoom(i,j)
				g1:insert(room)
				randChest = math.random(1,150)
				if(randChest == 1)then
					chest = Chest.new((i*tileSize),(j*tileSize))
					table.insert(chests,chest)
					g1:insert(chest.pic)
				end
				randMonster = math.random(1,100)
				if(randMonster == 1)then
					creature = Creature((i*tileSize),(j*tileSize))
					table.insert(creatures,creature)
					monsterGroup:insert(creature.model)
				elseif(randMonster == 2)then
					print("made a spider")
					spider = Spider((i*tileSize),(j*tileSize))
					table.insert(creatures,spider)
					monsterGroup:insert(spider.model)
				end
			elseif(adjMatrix[j][i] == 0 or adjMatrix[j][i] == 9)then
				wall = makeWall(i,j)
				g1:insert(wall)
			elseif(adjMatrix[j][i] == 2)then
				room = makeRoom(i,j)
				g1:insert(room)
				stairs = makeStairs(i,j)
				g1:insert(stairs)
			end-- end if
		end -- end inner for
	end--end outer for

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
	
	--set up music
	audio.pause(menuMusicChannel)
	audio.pause(bossMusicChannel)
	labyrinthMusicChannel = audio.play( labyrinthMusic, {channel=2, loops=-1, fadein=1000})
	
	if (tempHealth <= 0) then
		tempHealth = 100
	end
	chests = {}
	creatures = {}
	rooms = {}
	camera=PerspectiveLib.createView()
	physics.start()
	physics.setGravity(0,0)
	
	--g1 is the display group for the map that the user will be placed into
	g1 = display.newGroup()
	monsterGroup = display.newGroup()
	
if(floorsDone >= levels)then
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
	startRow = 5
	startCol = 5
	audio.pause(menuMusicChannel)
	audio.pause(labyrinthMusicChannel)
	bossMusicChannel = audio.play( bossMusic, {channel=3, loops=-1, fadein=1000})
else
	
	mask = display.newImageRect( "masked3.png", screenW, screenH )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0
	--Creates the intial starting room that the user will be placed into
	
	--define use for coordinates of last positioned room
	adjMatrix = {}
	rows = 62
	cols = 62
	for i=0,rows do
		adjMatrix[i] = {}
		for j=0,cols do
			if(i == 0 or i == 62 or i == 1 or i == 2 or i == 3 or i == 4 or i == 59 or i ==60 or i == 61 or i ==62)then
				adjMatrix[i][j] = 9
			elseif(j == 0 or j == 62 or j == 1 or j == 2 or j == 3 or j == 4 or j == 59 or j ==60 or j == 61 or j ==62)then 
				adjMatrix[i][j] = 9
			else
				adjMatrix[i][j] = 0
			end--end if
		end
	end
	
	local nodes = math.random(7,13)
	startRow = 0 --used for Rect's start position
	startCol = 0
	currentRow = 0
	currentCol = 0
	currentBotRow = 0
	currentBotCol = 0
	randomWalk(nodes)
	tunnels()
	generateMap(rows,cols)
end--end if for map generation
	

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
    	y = 17,
		native.systemFont,
		10
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
	
	downRect = display.newRect(rect.model.x , rect.model.y, 20,40)
	downRect:setReferencePoint(display.TopCenterReferencePoint)
	downRect.x = rect.model.x 
	downRect.y = rect.model.y
	downRect.id = "downRect"
	physics.addBody(downRect, "dynamic",{}) 
	downRect.isSensor = true
	
	rightRect = display.newRect(rect.model.x , rect.model.y, 40,20)
	rightRect:setReferencePoint(display.CenterLeftReferencePoint)
	rightRect.x = rect.model.x 
	rightRect.y = rect.model.y
	rightRect.id = "rightRect"
	physics.addBody(rightRect, "dynamic",{}) 
	rightRect.isSensor = true
	
	leftRect = display.newRect(rect.model.x , rect.model.y, 40,20)
	leftRect:setReferencePoint(display.CenterRightReferencePoint)
	leftRect.x = rect.model.x 
	leftRect.y = rect.model.y
	leftRect.id = "leftRect"
	physics.addBody(leftRect, "dynamic",{}) 
	leftRect.isSensor = true
	
	TRD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	TRD:setReferencePoint(display.BottomCenterReferencePoint)
	TRD.x = rect.model.x + rect.model.width*.5
	TRD.y = rect.model.y - rect.model.height*.1
	TRD.id = "TRD"
	physics.addBody(TRD, "dynamic",{}) 
	TRD.isSensor = true
	
	TLD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	TLD:setReferencePoint(display.BottomCenterReferencePoint)
	TLD.x = rect.model.x - rect.model.width*.5
	TLD.y = rect.model.y - rect.model.height*.1
	TLD.id = "TLD"
	physics.addBody(TLD, "dynamic",{}) 
	TLD.isSensor = true
	
	BLD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	BLD:setReferencePoint(display.TopCenterReferencePoint)
	BLD.x = rect.model.x - rect.model.width*.5
	BLD.y = rect.model.y + rect.model.height*.1
	BLD.id = "BLD"
	physics.addBody(BLD, "dynamic",{}) 
	BLD.isSensor = true

	BRD = display.newRect(rect.model.x, rect.model.y, 20,40) 
	BRD:setReferencePoint(display.TopCenterReferencePoint)
	BRD.x = rect.model.x + rect.model.width*.5
	BRD.y = rect.model.y + rect.model.height*.1
	BRD.id = "BRD"
	physics.addBody(BRD, "dynamic",{}) 
	BRD.isSensor = true
	
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
	group:insert( analogStick )
	group:insert( invBtn )
	group:insert( swordBtn )
	group:insert(healthBackground)
	group:insert(healthBar)
	group:insert(healthAmount)
	
end

local function main( event )
	analogStick:slide(rect,-rect.speed, true)
	
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
	audio.pause(menuMusicChannel)
	if (floorsDone < levels) then
		audio.pause(bossMusicChannel)
		audio.resume(labyrinthMusicChannel)
	else
		audio.pause(labyrinthMusicChannel)
		audio.resume(bossMusicChannel)
	end
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
	tempHealth = rect.health
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
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


Runtime:addEventListener( "collision", onCollision )
-----------------------------------------------------------------------------------------

return scene
