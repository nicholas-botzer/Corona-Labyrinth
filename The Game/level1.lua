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

local function onSwordBtnRelease()
	audio.play( swordClashSound )
	return true
end

local function onCollision( event )
    if ( event.phase == "began" ) then
		speed = 0
		playerHealth = playerHealth - 1
	elseif ( event.phase == "ended" ) then
		speed = 8.0
    end
end

local function updateHealth( event )
	healthAmount.text = playerHealth .. "/100"
	healthBar.width = playerHealth * 1.2			--decreases the red in the health bar by 1% of its width
	healthBar.x = 10 - ((100 - playerHealth) * .6)	--shifts the healthBar so it decreases from the right only
end					
								-- = starting X - ((playerMaxHealth - playerCurrentHealth) * half of 1% of the healthBar.width)
								
local function checkValidDir(r,c)
	if(adjMatrix[r][c] == 9 or adjMatrix[r][c] == 1)then
		return false
	end
	
	if(adjMatrix[r][c] == 0)then
		return true
	end
end

local function createEdge(direction)

	if(direction == 0 or direction == 2)then
		edgeHeight = math.random(100,400)
		edgeWidth = math.random(60,lastWidth/2)
		if(direction == 0)then
			edgeY = lastY - edgeHeight
		elseif(direction == 2)then
			edgeY = lastHeight + lastY
		end
		edgeX = math.random(lastX,(lastX + (lastWidth-edgeWidth)))
	elseif(direction == 1 or direction == 3)then
		edgeWidth = math.random(100,400)
		edgeHeight = math.random(60,lastHeight/2)
		if(direction == 1)then
			edgeX = lastX + lastWidth
		elseif(direction == 3)then
			edgeX = lastX - edgeWidth
		end
		edgeY = math.random(lastY,(lastY + (lastHeight-edgeHeight)))
	end
		
		
	--redefine the ending values of the edge just created so we can generate another room
	lastX = edgeX
	lastY = edgeY
	lastWidth = edgeWidth
	lastHeight = edgeHeight
	--create the connecting edge and return it to be added into the group
	edge = display.newRect(edgeX,edgeY,edgeWidth,edgeHeight)
	edge:setReferencePoint(display.TopLeftReferencePoint)
	edge.x, edge.y = edgeX , edgeY
	edge:setFillColor(0,0,255)
	
	return edge

end

local function createRoom(direction)

	roomWidth = math.random(200,600)
	roomHeight = math.random(200,600)
	if(direction == 2)then --downward room
		roomY = lastHeight + lastY
		roomX = math.random((lastX+lastWidth) - roomWidth,lastX)
	elseif(direction == 0)then --upward room
		roomY = lastY - roomHeight
		roomX = math.random((lastX+lastWidth) - roomWidth,lastX)
	elseif(direction == 1)then-- right room
		roomY = math.random(lastY-(roomHeight-lastHeight),lastY)
		roomX = lastX + lastWidth
	elseif(direction == 3)then-- left room
		roomY = math.random(lastY-(roomHeight-lastHeight),lastY)
		roomX = lastX - roomWidth
	end
	
	--roomX = math.random(0,400)
	--redefine ending values of room to generate next edge
	lastX = roomX
	lastY = roomY
	lastWidth = roomWidth
	lastHeight = roomHeight
	
	--create the room and return it, then add it to the group
	room = display.newRect(roomX,roomY,roomWidth,roomHeight)
    room:setReferencePoint(display.TopLeftReferencePoint)
    room.x,room.y = roomX, roomY
    room:setFillColor(0,255,0)
    
    return room
end

local function randomWalk(nodes,edges)
--use the adj matrix and begin a random walk through the grid

	--check open locations in matrix
	row = math.random(1,5)
	col = math.random(1,5)
	nodesPlaced = 0
	flag = false
	count = 0
	while nodesPlaced < nodes do
		--create the room at the start location
		adjMatrix[row][col] = 1
		--chooseRandom location and check if it is valid
		--if it's valid go that direction and change adjMatrix
		--if not check a new direction
		rand = math.random(0,3)
		flag = false
		count = 0
		while not flag and count < 4 do
			if(rand == 0)then
				flag = checkValidDir(row+1,col)
				if(flag)then
					--creates the edge going downward
					edge = createEdge(2)
					room = createRoom(2)
					row = row +1
				end
				count = count +1
			--creates edge going to the right
			elseif(rand == 1)then
				flag = checkValidDir(row,col+1)
				if(flag)then
					edge = createEdge(1)
					room = createRoom(1)
					col = col +1
				end
				count = count + 1
			--creates edge going upward
			elseif(rand == 2)then
				flag = checkValidDir(row-1,col)
				if(flag)then
					edge = createEdge(0)
					room = createRoom(0)
					row = row - 1
				end
				count = count + 1
			--creates edge going to the left
			elseif(rand == 3)then
				flag = checkValidDir(row,col-1)
				if(flag)then
					edge = createEdge(3)
					room = createRoom(3)
					col = col - 1
				end
				count = count + 1
			end
			rand = rand + 1
			if(rand > 3)then
				rand = 0
			end
		end	--end inner while
		g1:insert(room)
		g1:insert(edge)
		if(count >= 4)then
				test = display.newRect(screenW*.25, 0, 100, 100 )
				test:setReferencePoint( display.TopLeftReferencePoint )
				test:setFillColor(122,122,0)
				test.x, test.y = screenW*.25, 0
				g1:insert(test)
		end
		--for count equal four move to a neighbor that has an edge currently	
		nodesPlaced = nodesPlaced + 1
	end--end outer while signaling all nodes and edges have been placed



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
	physics.start()
	physics.setGravity(0,0)
	
	--g1 is the display group for the map that the user will be placed into
	g1 = display.newGroup()
	
	--[[mask = display.newImageRect( "masked2.png", screenW, screenH )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0]]
	--Creates the intial starting room that the user will be placed into
	ground = display.newRect(screenW*.25, 0, screenW*.4, 200 )
	ground:setReferencePoint( display.TopLeftReferencePoint )
	ground:setFillColor(255,0,0)
	ground.x, ground.y = screenW*.25, 0
	g1:insert(ground)
	
	
	--define use for coordinates of last positioned room
	--sets it to create a 5x5 grid of nodes with edges connecting the nodes
	adjMatrix = {}
	rows = 7
	cols = 7
	for i=0,rows do
		adjMatrix[i] = {}
		for j=0,cols do
			if(i == 0)then
				adjMatrix[i][j] = 9
			elseif(j == 0)then
				adjMatrix[i][j] = 9
			elseif(i == 9)then
				adjMatrix[i][j] = 9
			elseif(j == 9)then
				adjMatrix[i][j] = 9
			else
				adjMatrix[i][j] = 0
			end--end if
		end
	end
	
	local nodes = math.random(10,20)
	local edges = math.random(nodes,nodes*2)
	
	lastWidth = screenW*.4
	lastHeight = 200
	lastX = screenW*.25
	lastY = 0
	firstTime = 0
	
	randomWalk(nodes,edges)
	
	
	
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
		} )
	
	rect = display.newRect(screenW*.45, screenH*.5, 50, 50)
	rect.isBullet = true
	wall = display.newRect(screenW*.2, screenH*.5, 10, 200)
	physics.addBody(rect, { density=1, friction=0, bounce=0 })
	physics.addBody( wall , "static", { friction=0 })
	
	-- all display objects must be inserted into group in layer order 
	g1:insert(wall)
	group:insert(g1)
	group:insert( rect )
	--group:insert( mask )
	group:insert( analogStick )
	group:insert( invBtn )
	group:insert( swordBtn )
	group:insert(healthBackground)
	group:insert(healthBar)
	group:insert(healthAmount)
	
	--camera set up
	camera:add(rect, 2, true)
	camera:setFocus(rect)
	camera:setBounds(false)
	camera:track()
	group:insert( camera )
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
	analogStick:rotate(rect, true)
	analogStick:slide(g1, speed)
	
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

Runtime:addEventListener( "collision", onCollision )
-----------------------------------------------------------------------------------------

return scene
