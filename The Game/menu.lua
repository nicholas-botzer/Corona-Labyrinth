-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

--require("main") 
local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- forward declarations and other locals
local playBtn, optionsBtn, tutorialBtn
local menuMusic = audio.loadStream("MysticalCaverns.mp3")
	
	
------------ Function List ------------
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.removeScene("tutorial")
	composer.gotoScene( "level1", {effect="fade", time=500} )
	
	return true	-- indicates successful touch
end
local function onOptionsBtnRelease()
	
	-- go to options.lua scene
	composer.gotoScene( "options", {effect="fade", time=500} )
	
	return true	-- indicates successful touch
end
local function onTutorialBtnRelease()
	
	-- go to options.lua scene
	composer.removeScene("level1")
	composer.removeScene("inventory")
	composer.gotoScene( "tutorial", {effect="fade", time=500} )
	
	return true	-- indicates successful touch
end

--------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless composer.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

function scene:create ( event )
	local group = self.view

	--play menuMusic
	menuMusicChannel = audio.play(menuMusic, {channel=1, loops=-1, fadein=1000})
	
	-- set the background to the menu image
	local background = display.newImageRect( "Capture.PNG", display.contentWidth, display.contentHeight )
	background.anchorX, background.anchorY = 0, 0
	background.x, background.y = 0, 0
	
	--create the title text for the start menu screen
	local titleText = display.newImageRect("titleText.png", display.contentWidth*.85, display.contentHeight*.5)
	titleText.anchorX, titleText.anchorY = 0, 0
	titleText.x = display.contentWidth*.07
	titleText.y = display.contentHeight*.05
	
	-- create a widget button which will load level1.lua
	playBtn = widget.newButton{
		label="Play",
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=150, height=35,
		onRelease = onPlayBtnRelease
	}
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
function scene:show (event)
	local group = self.view
	composer.returnTo = "menu" 
	
	--stop all other music and resume playing the menu music
	if(labyrinthMusicChannel ~= nil) then
		audio.stop(labyrinthMusicChannel)
	end
	if (bossMusicChannel ~= nil) then
		audio.stop(bossMusicChannel)
	end
	audio.play(menuMusic, {channel=1, loops=-1, fadein=1000})
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	--remove all widgets
	if playBtn then
		playBtn:removeSelf()
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

-----------------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene