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
		speed = -8.0
		playerHealth = playerHealth - 1
	elseif ( event.phase == "ended" ) then
		speed = 8.0
    end
end

local function updateHealth( event )
	healthAmount.text = playerHealth .. "/100"
	healthBar.width = playerHealth * 1.2			--decreases the red in the health bar by 1% of its width
	healthBar.x = 10 - ((100 - playerHealth) * .6)	--shifts the healthBar so it decreases from the right only
end													-- = starting X - ((playerMaxHealth - playerCurrentHealth) * half of 1% of the healthBar.width)

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

	
	mask = display.newImageRect( "masked2.png", screenW, screenH )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0

	ground = display.newImageRect( "ground.jpg", 1600, 1600 )
	ground:setReferencePoint( display.TopLeftReferencePoint )
	ground.x, ground.y = 0, 0
	
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
	--group:insert( background )
	group:insert( ground )
	group:insert( rect )
	group:insert( wall )
	group:insert( mask )
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
	analogStick:slide(wall, speed)
	analogStick:slide(ground, speed)
	
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
