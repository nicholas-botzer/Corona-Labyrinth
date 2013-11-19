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
require("main") 

-- declarations
local rect, invBtn, screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local swordBtn
local swordClashSound = audio.loadSound("Sword clash sound effect.mp3")
local background, wall, ground, mask
local speed = 8.0

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
			speed = 0.0
        end
		if ( event.phase == "ended" ) then
			speed = 8.0
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
	physics.start()
	physics.setGravity(0,0)

	
	mask = display.newImageRect( "masked2.png", display.contentWidth, display.contentHeight )
	mask:setReferencePoint( display.TopLeftReferencePoint )
	mask.x, mask.y = 0, 0

	ground = display.newImageRect( "ground.jpg", 1600, 1600 )
	ground:setReferencePoint( display.TopLeftReferencePoint )
	ground.x, ground.y = 0, 0
	
	
	-- add an inventory button
	invBtn = widget.newButton{
		label="Inventory",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=40,
		onRelease = onInvBtnRelease	-- event listener function
	}
	invBtn:setReferencePoint( display.CenterReferencePoint )
	invBtn.x = display.contentWidth - invBtn.width * .5
	invBtn.y = invBtn.height * .5
	
	--add a swordBtn
	swordBtn = widget.newButton{
		label="Attack",
		labelColor = {default = {255}, over = {128} },
		defaultFile="swordIcon.png",
		overFile="swordIcon.png",
		width = 65, height = 75,
		onRelease = onSwordBtnRelease
	}
	swordBtn:setReferencePoint( display.CenterReferencePoint )
	swordBtn.x = 725
	swordBtn.y = 375
	
	-- adds an analog stick
	analogStick = StickLib.NewStick(
		{
			x = display.contentWidth * .1,
			y = display.contentHeight * .80,
			thumbSize = 60,
			borderSize = 55,
			snapBackSpeed = .35,
			R = 255,
			G = 255,
			B = 255
		} )
	
	rect = display.newRect(375, 225, 50 , 50)
	wall = display.newRect(200, 200, 10 , 200)
	physics.addBody(rect, { density=0, friction=0, bounce=0 })
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

Runtime:addEventListener( "collision", onCollision )
-----------------------------------------------------------------------------------------

return scene
