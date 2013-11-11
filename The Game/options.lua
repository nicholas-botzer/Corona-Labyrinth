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
    
    easyR.isVisible = false ; 
    medR.isVisible = false ; 
    hardR.isVisible = false ; 
    
    if(btnName == "easy") then 
    	easyR.isVisible = true ; 

    elseif(btnName == "med") then 
    	medR.isVisible = true ; 
    
    else 
    	hardR.isVisible = true ; 
    	
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
		width=154, height=40,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn:setReferencePoint( display.CenterReferencePoint )
	menuBtn.x = menuBtn.width * .5
	menuBtn.y = menuBtn.height * .5

    easyR = display.newRect(200, 240, 154, 40) 
    easyR:setReferencePoint(display.CenterReferencePoint) 
    easyR.x = 200 
    easyR.y = 240 
    easyR.isVisible = false ;
    easyR.strokeWidth = 3
    easyR:setFillColor(180,0,0)
    easyR:setStrokeColor(180,0,0) 
    
    medR = display.newRect(200, 240, 154, 40) 
    medR:setReferencePoint(display.CenterReferencePoint) 
    medR.x = 200 
    medR.y = 290 
    medR.isVisible = true ;
    medR.strokeWidth = 3
    medR:setFillColor(180,0,0)
    medR:setStrokeColor(180,0,0) 
    
    hardR = display.newRect(200, 240, 154, 40) 
    hardR:setReferencePoint(display.CenterReferencePoint) 
    hardR.x = 200 
    hardR.y = 340 
    hardR.isVisible = false ;
    hardR.strokeWidth = 3
    hardR:setFillColor(180,0,0)
    hardR:setStrokeColor(180,0,0) 
    
    easyMode = widget.newButton{
    	label="Easy",
    	labelColor = { default = {34,139,34}, over ={100,100,250}},
    	defaultFile="button.png",
    	overFile="button-over.png",
    	width=154, height=40,
    	onRelease = function() return onRelease("easy") end
    	
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
    	onRelease = function() return onRelease("med") end
    	
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
    	onRelease = function() return onRelease("hard") end
    	
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
	group:insert(easyR)
	group:insert(easyMode)
	group:insert(medR) 
	group:insert( mediumMode )
	group:insert(hardR)
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