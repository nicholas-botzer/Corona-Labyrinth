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
local playBtn, optionsBtn, tutorialBtn
local menuMusic = audio.loadStream("MysticalCaverns.mp3")
	
	
------------ Function List ------------
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	storyboard.purgeScene("tutorial")
	storyboard.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end
local function onOptionsBtnRelease()
	
	-- go to options.lua scene
	storyboard.gotoScene( "options", "fade", 200 )
	
	return true	-- indicates successful touch
end
local function onTutorialBtnRelease()
	
	-- go to options.lua scene
	storyboard.gotoScene( "tutorial", "fade", 200 )
	
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
	
	--play menuMusic
	menuMusicChannel = audio.play(menuMusic, {channel=1, loops=-1, fadein=1000})
	
	-- set the background to the menu image
	local background = display.newImageRect( "Capture.PNG", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
	--create the title text for the start menu screen
	local titleText = display.newImageRect("titleText.png", display.contentWidth*.85, display.contentHeight*.5)
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
	playBtn.x = display.contentWidth*.8
	playBtn.y = display.contentHeight * .70
	
	--create a button to allow the user to access the tutorial
	tutorialBtn = widget.newButton{
		label="Tutorial",
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=150, height=35,
		onRelease = onTutorialBtnRelease
	}
	tutorialBtn:setReferencePoint( display.CenterReferencePoint )
	tutorialBtn.x = display.contentWidth*.50
	tutorialBtn.y = display.contentHeight * .80
	
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
	optionsBtn.x = display.contentWidth * .20
	optionsBtn.y = display.contentHeight * .70
	
	-- all display objects must be inserted into group
	group:insert(background)
	group:insert(playBtn)
	group:insert(tutorialBtn)
	group:insert(titleText)
	group:insert(optionsBtn)
end

--Called immediately after scene has moved onscreen:
function scene:enterScene (event)
	local group = self.view
	storyboard.returnTo = "menu" 
	audio.resume(menuMusicChannel)
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
	if tutorialBtn then
		tutorialBtn:removeSelf()
		tutorialBtn = nil
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