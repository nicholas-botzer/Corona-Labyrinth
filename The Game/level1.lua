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
local PerspectiveLib = require("perspective")
local track = require ("track")
playerHeatlh = 100
floorsDone = 0
require("main") 
require("options")
require("ChestClass")


-- declarations
local rect, invBtn
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local swordBtn
local swordClashSound = audio.loadSound("Sword clash sound effect.mp3")
local background, wall, ground, mask

-- 'onRelease' event listener
local function onInvBtnRelease()
	-- go to inventory.lua scene
	storyboard.gotoScene( "inventory", "fade", 500 )
	return true	-- indicates successful touch
end


local function onSwordBtnRelease()
	--rect:pickAnimation()
	rect.model:play()
	audio.play( swordClashSound ) 
	
	--Handle swinging at enemies here
	if(enemyRect) then 
		--Test to see if enemy is range of player character. This can be a variable later. 
		if(math.abs(rect.model.x - enemyRect.x) < 30 and math.abs(rect.model.y - enemyRect.y) < 30) then
			enemyRect.health = enemyRect.health - 25 
			--Remove enemy if 0 HP or lower
			if (enemyRect.health <= 0) then 
				enemyRect:removeSelf() 
				enemyRect = nil 
			end
		end
	end

	--Handle chest opening here  
	--check all chests and use a flag
	flag = false
	chestNum = 1
	print("Player X:"..rect.model.x.."\nPlayerY:"..rect.model.y)
	while(not flag and chestNum <= table.getn(chests)) do
		--print(chests[chestNum])
		print("\nChestX:"..chests[chestNum].pic.x.."\nChestY:"..chests[chestNum].pic.y)
		if((math.abs(rect.model.x - chests[chestNum]:getX()) < 50) and (math.abs(rect.model.y - chests[chestNum]:getY()) < 50)) then
			print("detected in range")
			if(chests[chestNum].closed == true) then 
				chests[chestNum]:open() 
				local treasure = display.newText("You found a "..chests[chestNum]:getContents(), rect.model.x-65, rect.model.y-30, native.systemFontBold, 20) 
				table.insert(holding, chests[chestNum]:getContents()) 
				g1:insert(treasure) 
				timer.performWithDelay(1250, function() g1:remove(treasure) treasure = nil end)
				flag = true
			end--end if the chest is closed
		end--end checking if player is near chest
		chestNum = chestNum + 1
	end--end while
	
	if(floorsDone < levels)then
		if(math.abs(rect.model.x - stairs.x) < 120 and math.abs(rect.model.y - stairs.y) < 120)then
			floorsDone = floorsDone + 1
			storyboard.purgeScene("level1")
			storyboard.reloadScene("level1")
		end
	end
	
	return true
end 

local function onCollision( event )
	print("NO")
    if ( event.phase == "began" ) then
		rect.health = rect.health - 1
		analogStick:collided(true, analogStick:getAngle()) 
	elseif ( event.phase == "ended" ) then
		analogStick:collided(false, false)
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
	
	track.doFollow (boss, rect, boss.speed)
	
end	

function knockbackPlayer(attacker, player, force)
	local distanceX = player.model.x - attacker.model.x;
	local distanceY = player.model.y - attacker.model.y;
	local totalDistance = math.sqrt ( ( distanceX * distanceX ) + ( distanceY * distanceY ) )
	local moveDistX = distanceX / totalDistance;
	local moveDistY = distanceY / totalDistance;
	player.moveX = force /totalDistance
	player.moveY = force /totalDistance
	player.model.x = player.model.x + player.moveX
	player.model.y = player.model.y + player.moveY
end

function attackPlayer(attacker)
	
	if (math.abs(attacker.model.x - rect.model.x) < 40 and math.abs(attacker.model.y - rect.model.y) < 40) then
		rect.health = rect.health - (attacker.damage - rect.armor)
		knockbackPlayer(attacker, rect, 30)
	end
	
end
					
local function checkValidDir(r,c,botRow,botCol,dir)
	--subtract row 11 times making sure whole area is valid over 6 columns
	flag = true
	count = 0
	if(dir == 0)then
		for i=1,11 do
			for j=1,7 do
				if(adjMatrix[c+j][r-i] == 9 or count > 6)then
					return false
				elseif(adjMatrix[c+j][r-i] == 1)then
					count = count + 1
				end
			end
		end
	elseif(dir == 1)then
		for i=1,7 do
			for j=1,11 do
				if(adjMatrix[botCol+j][r+i] == 9 or count > 6)then
					return false
				elseif(adjMatrix[botCol+j][r+i] == 1)then
					count = count + 1
				end
			end
		end
	elseif(dir == 2)then
		for i=1,11 do
			for j=1,7 do
				if(adjMatrix[botCol+j][botRow+i] == 9 or count > 6)then
					return false
				elseif(adjMatrix[botCol+j][botRow+i] == 1)then
					count = count + 1
				end
			end
		end	
	elseif(dir == 3)then
		for i=1,7 do
			for j=1,11 do
				if(adjMatrix[c-j][r+i] == 9 or count > 6)then
					return false
				elseif(adjMatrix[c-j][r+i] == 1)then
					count = count + 1
				end
			end
		end	
	end--end if for direction
	
	if(count > 6)then
		return false
	else
		return true
	end

end

local function makeRoom(r,c)
    room = display.newImageRect("flooring.JPG",50,50)
    room:setReferencePoint(display.TopLeftReferencePoint)
    room.x,room.y = r*50,c*50
	
	return room
end
local function makeWall(r,c)
    wall = display.newImageRect("stone_wall.png",50,50)
    wall:setReferencePoint(display.TopLeftReferencePoint)
    wall.x,wall.y = r*50,c*50
	if(floorsDone == levels)then
		physics.addBody(wall,"dynamic",{})
	end
	
	return wall
end
function makeStairs(r,c)
	stairs = display.newImageRect("stairs.png",100,100)
	stairs:setReferencePoint(display.TopLeftReferencePoint)
	stairs.x,stairs.y = (r*50)-50,(c*50)-50
	
	return stairs

end
local function generateRoom(r,c,botRow,botCol,dir)
	
	width = math.random(3,5)
	height = math.random(3,5)
	if(dir == 0)then
		col = math.random((c+1)-width,c)
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
		col = math.random((c+1)-width,c)
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
		col = c - 1
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
end
local function generateEdge(r,c,botRow,botCol,dir)
	
	if(dir == 0 or dir == 2)then
		height = math.random(2,5)
		width = 1
		col = math.random(c,(botCol-1))
		for i=0,height do
			for j=0,width do
				if(dir == 0)then
					adjMatrix[col+j][r-i] = 1
				elseif(dir == 2)then
					adjMatrix[col+j][botRow+i] = 1
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
	elseif(dir == 1 or dir == 3)then
		height = 1
		width = math.random(2,5)
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
	print(levels) 
	currentRow = math.random(7,35)
	currentCol = math.random(7,35)
	startRow = currentRow + 1
	startCol = currentCol + 1
	currentBotRow = currentRow + 3
	currentBotCol = currentCol + 3
	generateStartRoom(currentRow,currentCol)
	nodesPlaced = 0
	flag = false
	while nodesPlaced < 12 do
		--create the room at the start location
		--chooseRandom location and check if it is valid
		--if it's valid go that direction and change adjMatrix
		--if not check a new direction
		rand = math.random(0,3)
		flag = false
		counter = 0
		while not flag and counter < 4 do
			if(rand == 0)then
				--check upward
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,0)
				if(flag)then
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,0)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,0)
				end
				counter = counter + 1
			--creates edge going to the right
			elseif(rand == 1)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,1)
				if(flag)then
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,1)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,1)
				end
				counter = counter + 1
			--creates edge going downward
			elseif(rand == 2)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,2)
				if(flag)then
					generateEdge(currentRow,currentCol,currentBotRow,currentBotCol,2)
					generateRoom(currentRow,currentCol,currentBotRow,currentBotCol,2)
				end
				counter = counter + 1
			--creates edge going to the left
			elseif(rand == 3)then
				flag = checkValidDir(currentRow,currentCol,currentBotRow,currentBotCol,3)
				if(flag)then
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
		--print(counter)
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

local function generateMap(rows,cols)
	
	for i=0,rows do
		for j=0,cols do
			if(adjMatrix[j][i] == 1)then
				room = makeRoom(i,j)
				g1:insert(room)
				rand = math.random(1,100)
				if(rand == 1)then
					chest = Chest.new((i*50),(j*50))
					table.insert(chests,chest)
					g1:insert(chest.pic)
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
			elseif(bossRoom[j][i] == 0 or bossRoom[j][i] == 9)then
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
	boss = Creature(110, 110)
	chests = {}
	camera=PerspectiveLib.createView()
	physics.start()
	physics.setGravity(0,0)
	
	--g1 is the display group for the map that the user will be placed into
	g1 = display.newGroup()
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
	
else
	--[[
	mask = display.newImageRect( "masked2.png", screenW, screenH )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0
	--Creates the intial starting room that the user will be placed into
	]]
	
	
	--define use for coordinates of last positioned room
	--sets it to create a 5x5 grid of nodes with edges connecting the nodes
	adjMatrix = {}
	rows = 42
	cols = 42
	for i=0,rows do
		adjMatrix[i] = {}
		for j=0,cols do
			if(i == 0 or i == 42)then
				adjMatrix[i][j] = 9
			elseif(j == 0 or j == 42)then 
				adjMatrix[i][j] = 9
			else
				adjMatrix[i][j] = 0
			end--end if
		end
	end
	
	local nodes = math.random(10,20)
	startRow = 0 --used for Rect's start position
	startCol = 0
	currentRow = 0
	currentCol = 0
	currentBotRow = 0
	currentBotCol = 0
	randomWalk(nodes)
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
	rect = Player(startRow * 50, startCol * 50) 
	--rect.x = startRow * 50  
	--rect.y = startCol * 50 
	
	--Helps with collision, sprite doesn't detect right side boundary properly  
	--colRect = display.newRect(rect.x, rect.y-25, 65, 60)
	--colRect.isVisible = false

	--physics.addBody(colRect, "kinematic", {})
	physics.addBody(rect.model, "dynamic", {})
	rect.model.isSensor = true
	
	---Sample chest ----
	

	--physics.addBody(chest1, "dynamic", {radius=20})
	---End of sample chest ----
	
	
	-- all display objects must be inserted into group in layer order 
	group:insert(g1)
	group:insert( rect.model )
	--group:insert( mask )
	
	--camera set up
	camera:add(g1,3,true)
	camera:add(rect.model, 2, true)
	camera:setFocus(rect.model)
	camera:setBounds(false)
	camera:track()
	group:insert( camera )
	group:insert( analogStick )
	group:insert( invBtn )
	group:insert( swordBtn )
	group:insert(healthBackground)
	group:insert(healthBar)
	group:insert(healthAmount)
	--group:insert(colRect)
	
	g1:insert(boss.model)
end

local function main( event )
        
	-- MOVE THE EVERYTHING
	
	analogStick:slide(rect.model,-rect.speed)
	angle = analogStick:getAngle() 
	moving = analogStick:getMoving()
	
	--Determine which animation to play based on the direction of the analog stick
	if(angle <= 70 or angle > 290) then
		seq = "forward"
	elseif(angle <= 110 and angle > 70) then
		seq = "right"
	elseif(angle <= 250 and angle > 160) then 
		seq = "back"
	elseif(angle <= 290 and angle > 250) then 
		seq = "left" 
	end
	
	--Change the sequence only if another sequence isn't still playing 
	if(not (seq == rect.model.sequence) and moving) then
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
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener( "enterFrame", main )
	Runtime:removeEventListener( "enterFrame", updateHealth )
	Runtime:removeEventListener( "enterFrame", trackPlayer)
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
