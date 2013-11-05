-----------------------------------------------------------------------------------------
--
-- options.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require "widget"

-- declarations
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-- 'onRelease' event listener
local function onMenuBtnRelease()
	-- go to menu.lua scene
	storyboard.gotoScene( "menu", "fade", 500 )
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
	local background = display.newRect( 0,0, display.contentWidth, display.contentHeight )
	background:setFillColor(255,235,205)
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
	menuBtn.x = 77
	menuBtn.y = 20
    
    easyMode = widget.newButton{
    	label="Easy",
    	labelColor = { default = {34,139,34}, over ={100,100,250}},
    	defaultFile="button.png",
    	overFile="button-over.png",
    	width=154, height=40,
    	
    }
    easyMode:setReferencePoint(display.CenterReferencePoint)
    easyMode.x = 200
    easyMode.y = 240
    
    mediumMode = widget.newButton{
    	label="Medium",
    	labelColor = { default = {0,0,225}, over ={100,100,250}},
    	defaultFile="button.png",
    	overFile="button-over.png",
    	width=154, height=40,
    	
    }
    mediumMode:setReferencePoint(display.CenterReferencePoint)
    mediumMode.x = 200
    mediumMode.y = 290
    
    hardMode = widget.newButton{
    	label="Hard",
    	labelColor = { default = {255,0,0}, over ={100,100,250}},
    	defaultFile="button.png",
    	overFile="button-over.png",
    	width=154, height=40,
    	
    }
    hardMode:setReferencePoint(display.CenterReferencePoint)
    hardMode.x = 200
    hardMode.y = 340
	local titleText = display.newText( "Options", display.contentWidth * .45, 50, "Canterbury" ,display.contentHeight * .1)
	titleText:setTextColor{ 0,0,0}
	
	local difficultyText = display.newText( "Difficulty", display.contentWidth * .15, 145, "Canterbury" ,display.contentHeight * .1)
	difficultyText:setTextColor{ 0,0,0}
	
	local levelsText = display.newText( "Levels", display.contentWidth * .7, 145, "Canterbury" ,display.contentHeight * .1)
	levelsText:setTextColor{ 0,0,0}
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert(easyMode)
	group:insert( menuBtn )
	group:insert( titleText )
	group:insert( difficultyText )
	group:insert( levelsText )
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
	if menuBtn then
		menuBtn:removeSelf()
		menuBtn = nil
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