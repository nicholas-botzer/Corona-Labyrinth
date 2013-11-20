-----------------------------------------------------------------------------------------
--
-- options.lua
--
-----------------------------------------------------------------------------------------

require("main") 
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

local function onRelease(btnName)    
    if(btnName == "easy") then 
    	selected.y = easyMode.y + 40*.5

    elseif(btnName == "med") then 
    	selected.y = mediumMode.y + 40*.5
    
    else 
    	selected.y = hardMode.y + 40 *.5
   
    end 
    return true ;
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
	local background = display.newImageRect( "optionsScreen.png", display.contentWidth, display.contentHeight )
	--background:setFillColor(255,235,205)
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0

	-- add a Menu button
	menuBtn = widget.newButton{
		label="Menu",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=30,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn:setReferencePoint( display.CenterReferencePoint )
	menuBtn.x = menuBtn.width * .5
	menuBtn.y = menuBtn.height * .5

    selected = display.newRect(200, 290, 158, 45) 
    selected:setReferencePoint(display.CenterReferencePoint) 
    selected.x = display.contentWidth *.15 + (154)*.5 
    selected.y = display.contentHeight *.45 + (40)*.5
    selected.strokeWidth = 3
    selected:setFillColor(180,0,0)
    selected:setStrokeColor(180,0,0) 

    easyMode = widget.newButton{
    	label="Easy",
    	labelColor = { default = {34,139,34}, over ={100,100,250}},
    	defaultFile="button.png",
    	overFile="button-over.png",
    	width=154, height=40,
    	onRelease = function() return onRelease("easy") end
    	
    }
    easyMode:setReferencePoint(display.TopLeftReferencePoint)
    easyMode.x = display.contentWidth * .15
    easyMode.y = display.contentHeight*.45
    
    mediumMode = widget.newButton{
    	label="Medium",
    	labelColor = { default = {0,0,225}, over ={100,100,250}},
    	defaultFile="button.png",
    	overFile="button-over.png",
    	width=154, height=40,
    	onRelease = function() return onRelease("med") end
    	
    }
    mediumMode:setReferencePoint(display.TopLeftReferencePoint)
    mediumMode.x = display.contentWidth * .15
    mediumMode.y = display.contentHeight*.60
    
    hardMode = widget.newButton{
    	label="Hard",
    	labelColor = { default = {255,0,0}, over ={100,100,250}},
    	defaultFile="button.png",
    	overFile="button-over.png",
    	width=154, height=40,
    	onRelease = function() return onRelease("hard") end
    }
    hardMode:setReferencePoint(display.TopLeftReferencePoint)
    hardMode.x = display.contentWidth * .15
    hardMode.y = display.contentHeight*.75
    
	local titleText = display.newText( "Options", display.contentWidth * .40, display.contentHeight*.15, "Canterbury" ,display.contentHeight * .1)
	titleText:setTextColor{ 0,0,0}
	
	local difficultyText = display.newText( "Difficulty", display.contentWidth * .15, display.contentHeight*.3, "Canterbury" ,display.contentHeight * .1)
	difficultyText:setTextColor{ 0,0,0}
	
	local levelsText = display.newText( "Levels", display.contentWidth * .7, display.contentHeight*.3, "Canterbury" ,display.contentHeight * .1)
	levelsText:setTextColor{ 0,0,0}
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( selected )	-- the red rectangle behind the difficulty
	group:insert( easyMode )
	group:insert( mediumMode )
	group:insert( hardMode )
	group:insert( menuBtn )
	group:insert( titleText )
	group:insert( difficultyText )
	group:insert( levelsText )
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
	if menuBtn then
		menuBtn:removeSelf()
		menuBtn = nil
	end
	if easyMode then
		easyMode:removeSelf()
		easyMode = nil
	end
	if mediumMode then
		mediumMode:removeSelf()
		mediumMode = nil
	end
	if mediumMode then
		mediumMode:removeSelf()
		mediumMode = nil
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