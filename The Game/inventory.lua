-----------------------------------------------------------------------------------------
--
-- inventory.lua
--
-----------------------------------------------------------------------------------------

require("main")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require "widget"

-- declarations
local backBtn, screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-- 'onRelease' event listener
local function onMenuBtnRelease()
	-- go to menu.lua scene
	storyboard.gotoScene( "menu", "fade", 500 )
	return true	-- indicates successful touch
end

local function onBackBtnRelease()
	storyboard.gotoScene( "level1", "fade", 250 )
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
	
	-- create a grey rectangle as the backdrop
	local background = display.newImageRect( "invScreen.png", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0

	-- add a Menu button
	menuBtn = widget.newButton{
		label="Menu",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=40,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn:setReferencePoint( display.CenterReferencePoint )
	menuBtn.x = menuBtn.width * .5
	menuBtn.y = menuBtn.height * .5

	
	backBtn = widget.newButton{
		label="Back",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=40,
		onRelease = onBackBtnRelease	-- event listener function
	}
	backBtn:setReferencePoint( display.CenterReferencePoint )
	backBtn.x = backBtn.width * .5
	backBtn.y = display.contentHeight - backBtn.height * .5
	
	
	local titleText = display.newText( "Inventory", display.contentWidth * .4, 50, "Canterbury" ,display.contentHeight * .1)
	titleText:setTextColor{ 0,0,0}
	
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( menuBtn )
	group:insert( backBtn )
	group:insert( titleText )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.returnTo = "level1"
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	if menuBtn then
		menuBtn:removeSelf()
		menuBtn = nil
	end
	if backBtn then
		backBtn:removeSelf()
		backBtn = nil
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

-----------------------------------------------------------------------------------------

return scene