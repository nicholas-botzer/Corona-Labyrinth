-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

require("main") 
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- forward declarations and other locals
local playBtn, optionsBtn

------------ Function List ------------
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	storyboard.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end
local function onOptionsBtnRelease()
	
	-- go to options.lua scene
	storyboard.gotoScene( "options", "fade", 200 )
	
	return true	-- indicates successful touch
end

--------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

function scene:createScene ( event )
	local group = self.view
	
	-- set the background to a gray color
	local background = display.newImageRect( "title.png", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
	
	local titleText = display.newImageRect("titleText.png", display.contentWidth*.85, display.contentHeight*.7)
	titleText:setReferencePoint(display.TopLeftReferencePoint)
	--titleText.x , titleText.y = 50, -50
	titleText.x = display.contentWidth*.07
	titleText.y = display.contentHeight*.05
	
	-- create a widget button which will load level1.lua
	playBtn = widget.newButton{
		label="Level 1",
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=150, height=35,
		onRelease = onPlayBtnRelease
	}
	playBtn:setReferencePoint( display.CenterReferencePoint )
	playBtn.x = display.contentWidth*.75
	playBtn.y = display.contentHeight * .85
	
	-- create a widget button which will load options.lua
	optionsBtn = widget.newButton{
		label="Options",
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=150, height=35,
		onRelease = onOptionsBtnRelease
	}
	optionsBtn:setReferencePoint( display.CenterReferencePoint )
	optionsBtn.x = display.contentWidth * .25
	optionsBtn.y = display.contentHeight * .85
	
	-- all display objects must be inserted into group
	group:insert(background)
	group:insert(playBtn)
	group:insert(titleText)
	group:insert(optionsBtn)
end

--Called immediately after scene has moved onscreen:
function scene:enterScene (event)
	local group = self.view
	storyboard.returnTo = "menu" 
	--insert code here (e.g. stop timers, remove listenets, unload sounds etc)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
	if optionsBtn then
		optionsBtn:removeSelf()
		optionsBtn = nil
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