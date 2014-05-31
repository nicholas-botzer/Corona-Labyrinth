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
floorType = 1
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
local labyrinthMusic = audio.loadStream("Battle Escape.mp3")
local bossMusic = audio.loadStream("battleThemeA.mp3")
currentScore = 0
-- 'onRelease' event listener
local function onInvBtnRelease()
	-- go to inventory.lua scene
	storyboard.gotoScene( "inventory", "fade", 150 )
	return true	-- indicates successful touch
end

--------------------------------
--This function re-evaluates item modifiers in the event of the scene being destroyed and re-entered
--One case where this is called is after stairs are taken
--Without this function item effects wouldn't carry out through various floors
-------------------------------
local function reequip() 
	if(inUse["sword"]) then
		rect.damage = rect.baseDamage + inUse["sword"].modifier 
	end
	if(inUse["armor"]) then
		rect.armor = rect.baseArmor + inUse["armor"].modifier
	end
	if(inUse["boots"]) then
		rect.speed = rect.baseSpeed + inUse["boots"].modifier 
	end
end

----------------------------
--This function is called when the scene is entered (in order to handle moving from the inventory screen back to level1.lua
--This function applies any items that were equipped while in the inventory screen (if any)
----------------------------
local function handleConsumption() --Inventory items take effect here 
	if(inUse["potion"]) then 
		rect.health = rect.health + inUse["potion"]
		if(rect.health > 100) then  --Don't allow health to exceed 100
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

-------------------
--This function tests to determine if the player already is holding the item that is passed to it
--Used to prevent duplicate items in the inventory screen 
-------------------
local function alreadyHolding(name) 
	containedFlag = false
	for i=1,table.getn(holding),1 do 
		if(holding[i] == name) then
			containedFlag = true
		end
	end
	return containedFlag 
end

local function characterIsFacing(enemy)
	local villian = enemy
	local vx = enemy.model.x
	local vy = enemy.model.y
	local x = rect.model.x
	local y = rect.model.y
	local direction = analogStick:getAngle()
	local attackable = false
	if(direction < 45 or direction > 315) then
		direction = "forward"
	elseif(direction > 45 and direction < 135) then
		direction = "right"
	elseif(direction > 135 and direction < 225) then
		direction = "behind"
	elseif(direction > 225 and direction < 315) then
		direction = "left"
	end
	
	if(direction == "forward" and vy <= y) then
		attackable = true
	elseif(direction == "right" and vx >= x) then
		attackable = true 
	elseif(direction == "left" and vx <= x) then
		attackable = true
	elseif(direction == "behind" and vy >= y) then
		attackable = true
	end
	return attackable
end
------------------------------------------
-- onSwordBtnRelease() 
-- checks to see if the player is in range to use stairs, hit enemies, and open chests
------------------------------------------
local function onSwordBtnRelease()
	-- change sprite and play audio
	rect:pickAnimation()
	rect.model:play()
	
	--check if player is on the boss floor
	if(floorsDone >= levels)then  
		if(creatures[1].isDead == true)then
			-- when the boss is dead goto the victory screen
			storyboard.gotoScene("victory", "fade", 500)
			storyboard.purgeScene("inventory")
			storyboard.purgeScene("level1")
		end
	end
	
	local stairsFlag = false;
	local creatureFlag = false;
	local chestFlag = false;
	--check to see if the player is trying to go to the next floor
	if(floorsDone < levels)then
		if(math.abs(rect.model.x - (stairs.x+50)) < 50 and math.abs(rect.model.y - (stairs.y+50)) < 50)then
			audio.play( stairsSound )
			floorsDone = floorsDone + 1
			tempHealth = rect.health
			storyboard.purgeScene("level1")
			storyboard.reloadScene("level1")
			stairsFlag = true;
		end
	end
	
	--Handle swinging at enemies here 
	--Test to see if enemy is range of player character.
	--Character must also be facing the enemy 
	monsterNum = 1
	while( monsterNum <= table.getn(creatures) and not stairsFlag )do
		if( not creatures[monsterNum].isDead)then		--only do range detection if the enemy is alive
			if(math.abs(rect.model.x - creatures[monsterNum].model.x) < 40 and math.abs(rect.model.y - creatures[monsterNum].model.y) < 40) then	--check the distance between the player and the creature
				if(characterIsFacing(creatures[monsterNum])) then
					creatures[monsterNum]:takeDamage(rect.damage)
					knockbackCreature(rect, creatures[monsterNum], 500)
					audio.play( swordClashSound ) 
					creatureFlag = true;
				end
			end--end if
		end
		monsterNum = monsterNum + 1
	end

	--Handle chest opening here  
	--check all chests and use a flag
	chestNum = 1
	while(chestNum <= table.getn(chests) and not stairsFlag) do
		if((math.abs(rect.model.x - chests[chestNum]:getX()) < 50) and (math.abs(rect.model.y - chests[chestNum]:getY()) < 50)) then
			if(chests[chestNum].closed == true) then 
				chests[chestNum]:open() 
				audio.play( openChestSound ) 
				chestFlag = true;
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
	if (not stairsFlag and not chestFlag and not creatureFlag) then
		audio.play( swordSwishSound ) 
	end
	return true
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
		storyboard.gotoScene("death")
		storyboard.purgeScene("inventory")
		storyboard.purgeScene("level1") 
	end
end					

------------------------------------------------------------------------------------------
--updateScore will update the current Score of the player
------------------------------------------------------------------------------------------
function updateScore()

	playerScore.text = "Score: "..currentScore

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
		--knockbackCreature(rect, monster, 300)
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

--[[ The checkValidDir function is used to check to make sure that there is available space
	to create a hallway and a room off of the current room. It does this by scanning the area
	in that direction and checking for the end of the map. It also counts how many room tiles have
	already been placed in that area and if that value exceeds 10 then it will not generate in that direction
]]					
local function checkValidDir(r,c,botRow,botCol,dir)
	
	count = 0
	if(dir == 0)then--scans to the left
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
	elseif(dir == 1)then --scans downward
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
	elseif(dir == 2)then --scans to the right
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
	elseif(dir == 3)then --scans in the upward direction
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
	--extra check to make sure that we didn't go over the count for amount of tiles already placed
	if(count > 10)then
		return false
	else
		return true
	end

end
--Creates the rooms tiles for the map that is generated. The floorType is choosen in the
--generateMap function and used for that floor of the dungeon
local function makeRoom(r,c)
	if(floorType == 1)then
		room = display.newImageRect("floors.png",tileSize,tileSize)
	elseif(floorType == 2)then
		room = display.newImageRect("floor2.png",tileSize,tileSize)
	elseif(floorType == 3)then
		room = display.newImageRect("floor3.png",tileSize,tileSize)
	end
    room:setReferencePoint(display.TopLeftReferencePoint)
    room.x,room.y = r*tileSize,c*tileSize
	
	return room
end
--Creates the wall tiles for the map and adds the physics to them for collision handling
local function makeWall(r,c)

	wall = display.newImageRect("walls.png",tileSize,tileSize)
    wall:setReferencePoint(display.TopLeftReferencePoint)
    wall.x,wall.y = r*tileSize,c*tileSize
	physics.addBody(wall,"static",{})
	
	return wall
end
local function makeWallNoPhysics(r,c)
	
	wall = display.newImageRect("walls.png",tileSize,tileSize)
    wall:setReferencePoint(display.TopLeftReferencePoint)
    wall.x,wall.y = r*tileSize,c*tileSize
	
	return wall


end
--Creates the stairs that allow the user to move onto the next floor
function makeStairs(r,c)
	stairs = display.newImageRect("stairs.png",100,100)
	stairs:setReferencePoint(display.TopLeftReferencePoint)
	stairs.x,stairs.y = (r*tileSize)-50,(c*tileSize)-50  --sets the location for the stair generation and moves it slighty to adjust for larger size
	
	return stairs

end
--[[
	The GenerateRoom function spawns the room off of a hallway that was selected by the algorithm.
	Dir - 0 spawns to the left
	Dir - 1 spawns downward
	Dir - 2 spawns to the right
	Dir - 3 spawns upward
]]
local function generateRoom(r,c,botRow,botCol,dir)
	
	width = math.random(3,5)--Allow's for different size rooms to be made
	height = math.random(3,5)
	if(dir == 0)then -- making a room to the left
		col = math.random((c+2)-width,c) --chooses which part of the room will be connected and varies it each time
		row = r -1
		for i=0,height do
			for j=0,width do
			    adjMatrix[col + j][row - i] = 1
			end
		end
		currentRow = r - height --sets the global values for knowledge of where the next area needs to begin spawning from
		currentCol = col
		currentBotRow = r - 1
		currentBotCol =  col + width
	elseif(dir == 1)then --spawning a room downward
		col = c + 1
		row = math.random((r-height + 1),r) --varies the connection point to the rooms 
		for i=0,height do
			for j=0,width do
			    adjMatrix[col+j][row+i] = 1
			end
		end
		currentRow = row --sets the global values for knowledge of where the next area needs to begin spawning from
		currentCol = col
		currentBotRow = row + height
		currentBotCol = col + width	
	elseif(dir == 2)then--spawning a room to the right
		row = r + 1
		col = math.random((c+2)-width,c)--varies connnection point to the room
		for i=0,height do
			for j=0,width do
			    adjMatrix[col+j][row+i] = 1
			end
		end
		currentRow = row --sets global values for knowledge of the next area that needs to spawn
		currentCol = col
		currentBotRow = row + height
		currentBotCol = col + width	
	elseif(dir == 3)then-- spawns a room upward
		col = c + 1
		row = math.random(r,(r+height))--varies the connection point between the rooms
		for i=0,height do
			for j=0,width do
			    adjMatrix[col-j][row-i] = 1
			end
		end
		currentRow = row - height --sets the globals for knowledge on the next area
		currentCol = col - width
		currentBotRow = row
		currentBotCol = col	
	end
	room = Room.new(currentRow,currentCol,currentBotRow,currentBotCol) -- creates an object with the info for each rooms key points
	table.insert(rooms,room) -- inserts it into a table to allow for tunnel generation
end
local function generateEdge(r,c,botRow,botCol,dir)
	
	if(dir == 0 or dir == 2)then --does spawning for the left and right directions of the hallways
		height = math.random(3,6)
		width = 2
		col = math.random(c,(botCol-1))--varies connecting location
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
--Spawn the start room that the user will be placed into
--This room will always be a 3X3 room
local function generateStartRoom(r,c)

	for i=0,3 do
		for j=0,3 do
			adjMatrix[c+j][r+i] = 1
		end
	end
end
local function randomWalk(nodes)
    --choose a starting location forced somewhere inward on the map for an intial location
	currentRow = math.random(15,45)
	currentCol = math.random(15,45)
	startRow = currentRow + 1 --get that start rooms and move into it for the player start spot
	startCol = currentCol + 1
	currentBotRow = currentRow + 3 --get the inital bottom of that room 
	currentBotCol = currentCol + 3
	generateStartRoom(currentRow,currentCol)--generate the start room in the adjMatrix with it's 3X3 size
	nodesPlaced = 0 --set the nodePlaced to 0 for each new floor
	flag = false --initalize the flag to false
	while nodesPlaced < nodes do --begin looping through to create all the rooms
		rand = math.random(0,3)--choose a random direction to check first to see if we can spawn that direction
		flag = false
		counter = 0 --counts how many of the directions have been invalid, if all four are bad the algorithm stops early and places the stairs
		while not flag and counter < 4 do --begin checking all 4 directions, if a room is placed then we move to the next spot
			if(rand == 0)then
				--check left
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,0)
				if(flag)then --generate a hallway and room to the left
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,0)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,0)
				end
				counter = counter + 1 --increment the counter for a unsuccessful room placement
			--creates edge going down
			elseif(rand == 1)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,1)
				if(flag)then --generating a rooms going downward
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,1)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,1)
				end
				counter = counter + 1 --increment the counter for unsuccessful room placement
			--creates edge going to the right
			elseif(rand == 2)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,2)
				if(flag)then--generate a room to the right
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,2)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,2)
				end
				counter = counter + 1 --increment counter for unsuccessful room placement
			--creates edge going up
			elseif(rand == 3)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,3)
				if(flag)then--generate room going upward
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,3)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,3)
				end
				counter = counter + 1--increment counter for unsuccessful room placement
			end
			rand = rand + 1 --increment rand to check the next room direction
			if(rand > 3)then -- put rand back to zero if we have made it around
				rand = 0
			end
		end	--end inner while
		if(counter >= 4 and not flag)then --no room was placed so end the algorithm by setting stairs and uping nodesPlaced
			adjMatrix[currentCol + 2][currentRow + 2] = 2
			nodesPlaced = 50
		else
			nodesPlaced = nodesPlaced + 1
		end--end if
	end--end outer while signaling all nodes and edges have been placed
	adjMatrix[currentCol + 2][currentRow + 2] = 2 --places stairs

end
--tunnels connects some of the rooms that are further apart so that there a more passageways for the player to go through
local function tunnels()
	
	numRooms = table.getn(rooms)--gets the number of rooms spawned
	for i=0,3 do -- chooses to make three connection tunnels between rooms
		randRoom = math.random(1,numRooms)
		rooms[randRoom]:connectRooms(rooms[math.random(1,numRooms-1)])
	end
end
local function setWalls(rows,cols)

	for i=0,rows do
		for j=0,cols do
			if(adjMatrix[j][i] == 1)then
				local rowChange = -1
				local colChange = -1
				for x=1,9 do
					if(adjMatrix[j + colChange][i + rowChange] == 0)then
						adjMatrix[j + colChange][i + rowChange] = 3
					end
					colChange = colChange + 1
					if(x%3 == 0)then
						colChange = -1
						rowChange = rowChange + 1
					end
				end--end for x loop
			end--end if
		end--end  for j
	end--end for i 


end
local function generateMap(rows,cols)
	
	floorType = math.random(1,3)--determines what type of floor tiles we will used the keep the maps looking interesting
	for i=0,rows do --goes through to generate every single tile of the entire map
		for j=0,cols do
			if(adjMatrix[j][i] == 1)then --generates a floor tile 
				room = makeRoom(i,j)
				g1:insert(room)
				randChest = math.random(1,150) --creates a random chance that a chest will spawn on the floor tile
				if(randChest == 1)then--checks to see if one spawned
					chest = Chest.new((i*tileSize),(j*tileSize))--creates the chest
					table.insert(chests,chest)--adds the chest to the table holding them
					g1:insert(chest.pic)--inserts the chest onto the map
				end
				randMonster = math.random(1,100)--random chance to spawn a monster
				if(randMonster == 1)then--checks to see if a skeleton will be map
					creature = Creature((i*tileSize),(j*tileSize))--creates a skeleton
					table.insert(creatures,creature)--adds the skeleton to the list
					monsterGroup:insert(creature.model)--inserts the skeleton into the monsterGroup
				elseif(randMonster == 2)then--checks for a spider spawn
					spider = Spider((i*tileSize),(j*tileSize))--creates a spider
					table.insert(creatures,spider)--inserts the spider into the table
					monsterGroup:insert(spider.model)--inserts the spider into the monsterGroup
				end
			elseif(adjMatrix[j][i] == 3 or adjMatrix[j][i] == 9)then--checks to make a wall
				wall = makeWall(i,j)--creates a wall
				g1:insert(wall)
			elseif(adjMatrix[j][i] == 0)then
				wall = makeWallNoPhysics(i,j) --creates a wall without physics
				g1:insert(wall)
			elseif(adjMatrix[j][i] == 2)then--checks to make stairs
				room = makeRoom(i,j)--creates a floor tile
				g1:insert(room)
				stairs = makeStairs(i,j)--creates the stairs that go on top of the floor tile
				g1:insert(stairs)
			end-- end if
		end -- end inner for
	end--end outer for

end
--creates the boos room for the final floor
local function generateBossRoom(rows,cols)
--generates the boos room which will be the same size every time
	for i=0,rows do
		for j=0,cols do
			if(bossRoom[j][i] == 1)then --generates a floor tile
				room = makeRoom(i,j)
				g1:insert(room)
			elseif(bossRoom[j][i] == 3 or bossRoom[j][i] == 9)then --generates a wall tile
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
	--audio.pause(menuMusicChannel)
	--audio.pause(bossMusicChannel)
	labyrinthMusicChannel = audio.play( labyrinthMusic, {channel=2, loops=-1, fadein=1000})
	
	if (tempHealth <= 0) then --tempHealth is used to reset the player's health on each new floor
		tempHealth = 100      --this check determines that the player died and is starting over
	end
	chests = {} --holds all of the chests that will be spawned onto the map
	creatures = {} --holds all of the monsters that get spawn onto the map
	rooms = {} --holds all the rooms so we can create tunnels between them
	camera=PerspectiveLib.createView() --creates the camera that will track the player for us
	physics.start()     --generates the starting physics for the game
	physics.setGravity(0,0)
	
	--g1 is the display group for the map that the user will be placed into
	g1 = display.newGroup()
	--monsterGroup holds all of the monsters on it that get placed on the map
	monsterGroup = display.newGroup()
	--mask that limits the player vision slightly, the mask also turns red briefly upon taking damage
	mask = display.newImageRect( "masked3.png", screenW, screenH )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0
	--red mask that shows up when the user takes damage
	dmgMask = display.newImageRect( "masked3_dmg.png", screenW, screenH )
	dmgMask:setReferencePoint( display.TopLeftReferencePoint )
	dmgMask.x, dmgMask.y = 0, 0
	dmgMask.isVisible = false
	
if(floorsDone >= levels)then --checks to see if the player is on the boos floor
	bossRoom = {} 
	for x=0,9 do --generates the boss room that the user will be placed into to fight the evil demon
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
	generateBossRoom(9,9)--spawns the boss room
	startRow = 5 --initalizes the location that the user will be placed at to start
	startCol = 5
	creature = Demon((5*tileSize),(3*tileSize))--creates the evil demon the player will fight
	table.insert(creatures, creature)
	monsterGroup:insert(creature.model)
	--start the awsome boss fight music
	bossMusicChannel = audio.play( bossMusic, {channel=3, loops=-1, fadein=1000})
else --the player still has to make progress in the labyrinthian and must fight through another floor
	
	--define use for coordinates of last positioned room
	adjMatrix = {} --holds the map grid that will be used for map generation
	rows = 62 --the size that the map is overall
	cols = 62
	for i=0,rows do
		adjMatrix[i] = {}
		for j=0,cols do
			if(i == 0 or i == 62 or i == 1 or i == 2 or i == 3 or i == 4 or i == 59 or i ==60 or i == 61 or i ==62)then
				adjMatrix[i][j] = 9 -- creates a binding box along the outside of the map to signify the edge for the algorithm
			elseif(j == 0 or j == 62 or j == 1 or j == 2 or j == 3 or j == 4 or j == 59 or j ==60 or j == 61 or j ==62)then 
				adjMatrix[i][j] = 9 -- the binding box is more than 1 deep to make it run smother and ensure no errors
			else
				adjMatrix[i][j] = 0 --creates a blank spot that originally signifies a wall but can be turned into a room tile
			end--end if
		end
	end
	
	local nodes = math.random(7,13) --deteremines how many rooms should get generated for a particular floor
	startRow = 0 --used for Rect's start position
	startCol = 0
	currentRow = 0 --holds the global's that we will use so the next room and hallway can be spawned
	currentCol = 0
	currentBotRow = 0
	currentBotCol = 0
	randomWalk(nodes)--calls the randomwalk algorithm to begin determining how the map will be
	tunnels()   --creates a few extra connectiong "tunnels" that make the map more confusing and interesting
	setWalls(rows,cols)
	generateMap(rows,cols)  --actually spawns the map to the screen, places the monsters, and spawns chests
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
    
	--holds the text that displays the player's current health
    healthAmount = display.newText {
    	text = "100/100", --defualt value, gets overwritten in updateHealth()
    	x = 70,
    	y = 17,
		native.systemFont,
		10
    }
	
	playerScore = display.newText {
		text = "Score:"..currentScore, --start score for the player
		x = display.contentWidth * .45,
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
	swordBtn.x = screenW - swordBtn.width*.7 
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
	reequip()
	
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
	group:insert(playerScore)
	
end

local function main( event )
	analogStick:slide(rect,-rect.speed)
	if(floorsDone == 0 and not fixed) then  
		fixed = true
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

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	--creates the eventListeners that are needed to handle different functions
	Runtime:addEventListener( "enterFrame", main )
	Runtime:addEventListener( "enterFrame", updateHealth ) --listens for changing health
	Runtime:addEventListener( "enterFrame", trackPlayer) --makes the enimies track the player
	storyboard.returnTo = "menu" 
	handleConsumption()  --Determine if any items were placed onto the player/potions used
	audio.stop(menuMusicChannel)
	if (floorsDone < levels) then
		audio.stop(bossMusicChannel)
		audio.play(labyrinthMusic, {channel=2, loops=-1, fadein=1000})
	else
		audio.stop(labyrinthMusicChannel)
		audio.play(bossMusic, {channel=3, loops=-1, fadein=1000})
	end
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	--Removes all of the eventListeners because the scene has changed and they need destroyed
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
	tempHealth = rect.health
end

-- If scene's view is removed, scene:Scene() will be called just prior to:
function scene:destroyScene( event )
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

-----------------------------------------------------------------------------------------

return scene
