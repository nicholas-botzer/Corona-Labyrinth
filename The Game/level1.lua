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

-- declarations
local rect, invBtn, screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-- 'onRelease' event listener
local function onInvBtnRelease()
	-- go to inventory.lua scene
	storyboard.gotoScene( "inventory", "fade", 500 )
	return true	-- indicates successful touch
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
	-- create a grey rectangle as the backdrop
	local background = display.newImageRect( "title.png", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0

	-- add an inventory button
	invBtn = widget.newButton{
		label="Inv",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=40,
		onRelease = onInvBtnRelease	-- event listener function
	}
	invBtn:setReferencePoint( display.CenterReferencePoint )
	invBtn.x = 800 - 77
	invBtn.y = 20
	
	analogStick = StickLib.NewStick(
		{
			x = display.contentWidth * .1,
			y = display.contentHeight * .80,
			thumbSize = 50,
			borderSize = 30,
			snapBackSpeed = .75,
			R = 255,
			G = 255,
			B = 255
		} )
	
	rect = display.newRect(50, 50, 50 , 50)
	local wall = display.newRect(400, 200, 10 , 200)
	physics.addBody(rect, { density=1, friction=0.1, bounce=1 })
	physics.addBody(wall, "static", {friction=.5})
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( analogStick )
	group:insert( invBtn )
	group:insert( rect )
	group:insert( wall )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
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
        
        -- MOVE THE SHIP
        analogStick:move(rect, 7.0, true)

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
-----------------------------------------------------------------------------------------

return scene