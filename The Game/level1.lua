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
local CreatureClasses = require('CreatureClasses')
local PerspectiveLib = require("perspective")
require("main") 

-- declarations
local rect, invBtn
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local swordBtn
local swordClashSound = audio.loadSound("Sword clash sound effect.mp3")
local background, wall, ground, mask
local speed = 8.0
local playerHealth = 100
local camera=PerspectiveLib.createView()



-- 'onRelease' event listener
local function onInvBtnRelease()
	-- go to inventory.lua scene
	storyboard.gotoScene( "inventory", "fade", 500 )
	return true	-- indicates successful touch
end

--Picks combat animation based on which way the player is facing
local function pickAnimation() 
	facing = rect.sequence 
	if(facing == "forward") then 
		rect:setSequence("attackForward")
	elseif(facing == "right") then 
		rect:setSequence("attackRight") 
	elseif(facing == "back") then
		rect:setSequence("attackBack") 
	elseif(facing == "left") then
		rect:setSequence("attackLeft") 
	end
end

local function onSwordBtnRelease()
	pickAnimation()
	rect:play()
	if(enemyRect) then 
		--Test to see if enemy is range of player character. This can be a variable later. 
		if(math.abs(rect.x - enemyRect.x) < 30 and math.abs(rect.y - enemyRect.y)) then
			enemyRect.health = enemyRect.health - 25 
			audio.play( swordClashSound ) 
			--Remove enemy if 0 HP or lower
			if (enemyRect.health <= 0) then 
				enemyRect:removeSelf() 
				enemyRect = nil 
			end
		end
	end
	
	--Open a chest if its in range
	if(math.abs(rect.x - chest1.x) < 30 and math.abs(rect.y - chest1.y)) then
		if(chest1.frame == 1) then  --Only lets chest animation play if the chest is closed
			chest1:setSequence("open") 
			chest1:play() 
			treasure = display.newText("You found a ".."Giant Cock", rect.x, rect.y) 
			timer.performWithDelay(1000, function() treasure:removeSelf() treasure = nil end)
			items[table.getn(items)] = "Object Name"
		end
	end

	return true
end 

local function onCollision( event )
    if ( event.phase == "began" ) then
		playerHealth = playerHealth - 1
		analogStick:collided(true, analogStick:getAngle()) 
	elseif ( event.phase == "ended" ) then
		analogStick:collided(false, false)
    end
end

local function updateHealth( event )
	healthAmount.text = playerHealth .. "/100"
	healthBar.width = playerHealth * 1.2			--decreases the red in the health bar by 1% of its width
	healthBar.x = 10 - ((100 - playerHealth) * .6)	--shifts the healthBar so it decreases from the right only
	if(playerHealth <= 0) then
		storyboard.gotoScene( "menu" )
		--storyboard.purgeScene("level1")
		--physics.removeBody(wall)
		--physics.stop()
		--analogStick:delete()
		--camera:destroy() 
	end
end					
								-- = starting X - ((playerMaxHealth - playerCurrentHealth) * half of 1% of the healthBar.width)
								
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
	
	return wall
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
		print(counter)
		if(counter >= 4 and not flag)then
			adjMatrix[2][2] = 1
			nodesPlaced = nodesPlaced + 1
		else
			nodesPlaced = nodesPlaced + 1
		end
	end--end outer while signaling all nodes and edges have been placed

end

local function generateMap(rows,cols)
	
	for i=0,rows do
		for j=0,cols do
			if(adjMatrix[i][j] == 1)then
				room = makeRoom(i,j)
				g1:insert(room)
			elseif(adjMatrix[i][j] == 0 or adjMatrix[i][j] == 9)then
				wall = makeWall(i,j)
				g1:insert(wall)
			end-- end if
		end -- end inner for
	end--end outer for

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
	physics.start()
	physics.setGravity(0,0)
	
	--g1 is the display group for the map that the user will be placed into
	g1 = display.newGroup()
	
	--[[mask = display.newImageRect( "masked2.png", screenW, screenH )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0
	--Creates the intial starting room that the user will be placed into
	ground = display.newRect(screenW*.25, 0, screenW*.4, 200 )
	ground:setReferencePoint( display.TopLeftReferencePoint )
	ground:setFillColor(255,0,0)
	ground.x, ground.y = screenW*.25, 0
	g1:insert(ground)]]
	
	
	--define use for coordinates of last positioned room
	--sets it to create a 5x5 grid of nodes with edges connecting the nodes
	adjMatrix = {}
	rows = 42
	cols = 42
	for i=0,rows do
		adjMatrix[i] = {}
		for j=0,cols do
			if(i == 0)then
				adjMatrix[i][j] = 9
			elseif(j == 0)then
				adjMatrix[i][j] = 9
			elseif(i == 42)then
				adjMatrix[i][j] = 9
			elseif(j == 42)then
				adjMatrix[i][j] = 9
			else
				adjMatrix[i][j] = 0
			end--end if
		end
	end
	
	local nodes = math.random(10,20)
	startRow = 0
	startCol = 0
	--[[lastWidth = screenW*.4
	lastHeight = 200
	lastX = screenW*.25
	lastY = 0
	firstTime = 0]]
	currentRow = 0
	currentCol = 0
	currentBotRow = 0
	currentBotCol = 0
	randomWalk(nodes)
	generateMap(rows,cols)
	
	
	
	--[[incase something messes up and i need to go back to it
	lastWidth = screenW*.25
	lastHeight = 200
	lastX = screenW*.25
	lastY = 0
	
	
	for i=1,5 do
		 edgey = createEdge();
		 room = createRoom()
		 g1:insert(edgey)
		 g1:insert(room)
	end]]
	

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
    	text = playerHealth .. "/100",
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
			x = screenW * .1,
			y = screenH * .75,
			thumbSize = 50,
			borderSize = 55,
			snapBackSpeed = .35,
			R = 255,
			G = 255,
			B = 255
		} 
	)
	
	sequenceData = {
		{name = "forward", frames={1,2,3,0}, time = 1000, loopCount = 1},
		{name = "right", frames={4,5,6,0}, time = 1000, loopCount = 1}, 
		{name = "back", frames= {7,8,9,0}, time = 1000, loopCount = 1}, 
		{name = "left", frames={10,11,12,0}, time = 1000, loopCount = 1},
		{name = "attackForward", frames={3,1,3}, time = 200, loopCount = 1},
		{name = "attackRight", frames={6,7,6}, time = 200, loopCount = 1},
		{name = "attackLeft", frames={11,12,12}, time = 200, loopCount = 1},
		{name = "attackBack", frames={8,10,8}, time = 200, loopCount = 1},

	}

	--Declare Image Sheet 
	spriteOptions = {	
		height = 32, 
		width = 24, 
		numFrames = 12, 
		sheetContentWidth = 72, 
		sheetContentHeight = 128 
	}
 
	mySheet = graphics.newImageSheet("knight3.png", spriteOptions) 
	
	--Declare Sprite Object 
	rect = display.newSprite(mySheet, sequenceData) 
	rect.x = startCol * 50  
	rect.y = startRow * 50 
	
	--Helps with collision, sprite doesn't detect right side boundary properly  
	colRect = display.newRect(rect.x, rect.y-25, 65, 60)
	colRect.isVisible = true
	
	--Represents a potential enemy, used to test attack button
	enemyRect = display.newRect(-50,-50, 20,20) 
	enemyRect.health = 50
	enemyRect:setFillColor(0,0,255)
		
	walle = display.newRect(100, 100, 200, 200)
	walle:setFillColor(255,0,0)
	physics.addBody(colRect, "kinematic", {})
	physics.addBody(enemyRect, "dynamic", {})
	physics.addBody(rect, "static", {})
	physics.addBody( walle , "dynamic", {})
	walle.isSensor = true 
	
	---Sample chest ----
	chestData = {
		{name = "open", frames={1, 5, 2, 2}, time = 1000, loopCount = 1},
	}
	
	chestDetails = {	
		height = 32, 
		width = 32, 
		numFrames = 6, 
		sheetContentWidth = 96, 
		sheetContentHeight = 64 
	}
	
	chestSheet = graphics.newImageSheet("chestResize.png", chestDetails) 
	chest1 = display.newSprite(chestSheet, chestData)
	chest1.x = 100 
	chest1.y = 50
	--physics.addBody(chest1, "dynamic", {radius=20})
	---End of sample chest ----
	
	
	-- all display objects must be inserted into group in layer order 
	group:insert(g1)
	group:insert(walle)
	group:insert( rect )
	--group:insert( mask )
	
	--camera set up
	camera:add(g1,3,true)
	camera:add(rect, 2, true)
	camera:setFocus(rect)
	camera:setBounds(false)
	camera:track()
	group:insert( camera )
	group:insert( analogStick )
	group:insert( invBtn )
	group:insert( swordBtn )
	group:insert(healthBackground)
	group:insert(healthBar)
	group:insert(healthAmount)
	group:insert(colRect)
	group:insert(enemyRect)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.returnTo = "menu" 
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	if invBtn then
		invBtn:removeSelf()
		invBtn = nil
	end
end

local function main( event )
        
	-- MOVE THE EVERYTHING
	analogStick:slide(g1, speed)
	analogStick:slide(walle, speed) 
	analogStick:slide(chest1, speed)
	if(enemyRect) then 
		analogStick:slide(enemyRect, speed)
	end
	
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
	if(not (seq == rect.sequence) and moving) then
		rect:setSequence(seq)
	end
	
	--If the analog stick is moving, animate the sprite
	if(moving) then 
		rect:play() 
	end
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

Runtime:addEventListener( "enterFrame", main )
Runtime:addEventListener( "enterFrame", updateHealth )

--Runtime:addEventListener( "collision", onCollision )
-----------------------------------------------------------------------------------------

return scene
