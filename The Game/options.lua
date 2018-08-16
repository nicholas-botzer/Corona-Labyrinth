-----------------------------------------------------------------------------------------
--
-- options.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
--local ads = require ("ads")
difficulty = 1
levels = math.random(3,5)


local widget = require "widget"

-- declarations
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-- 'onRelease' event listener
local function onCreditsBtnRelease()
	-- go to credits.lua scene
	composer.gotoScene( "gamecredits", {effect="fade", time=500} )
	return true	-- indicates successful touch
end
local function onMenuBtnRelease()
	-- go to menu.lua scene
	composer.gotoScene( "menu", {effect="fade", time=500} )
	return true	-- indicates successful touch
end


local function onRelease(btnName)    
    if(btnName == "easy") then 
    	selected.y = easyMode.y + 20
		difficulty = 1
    elseif(btnName == "med") then 
    	selected.y = mediumMode.y + 20
    	difficulty = 2
    else 
    	selected.y = hardMode.y + 20
   		difficulty = 3    
	end 
    return true ;
end

local function levelSelected(level)

	if(level == "low") then
		selected2.y = lowLevels.y + 20
		levels = math.random(3,5)
	elseif(level == "medium") then
		selected2.y = midLevels.y + 20
		levels = math.random(6,8)
	else
		selected2.y = highLevels.y + 20
		levels = math.random(9,11)
	end
	return true ;
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless composer.remove() is called.
--
-----------------------------------------------------------------------------------------
local function adListener( event )
    if ( event.isError ) then
        print("didnt show ad")
    end
end


function scene:create (event)
	local group = self.view
	
	-- create a grey rectangle as the backdrop
	local background = display.newImageRect( "Images/optionsScreen.png", display.contentWidth, display.contentHeight )
	background.anchorX, background.anchorY = 0, 0
	background.x, background.y = 0, 0
	
	
	-- add a Menu button
	menuBtn = widget.newButton{
		label="Menu",
		labelColor = { default = {255}, over= {128} },
		defaultFile="Images/button.png",
		overFile="Images/button-over.png",
		width=154, height=30,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn.x = menuBtn.width * .5
	menuBtn.y = menuBtn.height * .5
	
	creditsBtn = widget.newButton{
		label="Credits",
		labelColor = { default = {255}, over= {128} },
		defaultFile="Images/button.png",
		overFile="Images/button-over.png",
		width=154, height=30,
		onRelease = onCreditsBtnRelease	-- event listener function
	}
	creditsBtn.x = display.contentWidth - creditsBtn.width * .5
	creditsBtn.y = creditsBtn.height * .5

	--create a red rectangle to be placed behind the difficulty widgets
    selected = display.newRect(200, 290, 158, 45) 
    selected.x = display.contentWidth *.15 + (154)*.5 
    selected.y = display.contentHeight *.45 + (40)*.5
    selected.strokeWidth = 3
    selected:setFillColor(180,0,0)
    selected:setStrokeColor(180,0,0)
    
	--create a red rectangle to be placed behind the number of floors widgets
    selected2 = display.newRect(400,290,158,45)
    selected2.x = display.contentWidth *.67 + (154)*.5
    selected2.y = display.contentHeight *.45+ (40)*.5
    selected2.strokeWidth = 3
    selected2:setFillColor(180,0,0)
    selected2:setStrokeColor(180,0,0)
	
	--begin creation of mode buttons
	
    easyMode = widget.newButton{
    	label="Easy",
    	labelColor = { default = {34,139,34}, over ={100,100,250}},
    	defaultFile="Images/button.png",
    	overFile="Images/button-over.png",
    	width=154, height=40,
    	onRelease = function() return onRelease("easy") end
    	
    }
	easyMode.anchorX, easyMode.anchorY = 0, 0
    easyMode.x = display.contentWidth * .15
    easyMode.y = display.contentHeight*.45
    
    mediumMode = widget.newButton{
    	label="Medium",
    	labelColor = { default = {0,0,225}, over ={100,100,250}},
    	defaultFile="Images/button.png",
    	overFile="Images/button-over.png",
    	width=154, height=40,
    	onRelease = function() return onRelease("med") end
    	
    }
	mediumMode.anchorX, mediumMode.anchorY = 0, 0
    mediumMode.x = display.contentWidth * .15
    mediumMode.y = display.contentHeight*.60
    
    hardMode = widget.newButton{
    	label="Hard",
    	labelColor = { default = {255,0,0}, over ={100,100,250}},
    	defaultFile="Images/button.png",
    	overFile="Images/button-over.png",
    	width=154, height=40,
    	onRelease = function() return onRelease("hard") end
    }
	hardMode.anchorX, hardMode.anchorY = 0, 0
    hardMode.x = display.contentWidth * .15
    hardMode.y = display.contentHeight*.75
    
    --begin creation of levels button
    
    lowLevels = widget.newButton{
    	label="3 - 5",
    	labelColor = { default = {34,139,34}, over={100,100,250}},
    	defaultFile="Images/button.png",
    	overFile="Images/button-over.png",
    	width=154, height=40,
    	onRelease = function() return levelSelected("low") end
    }
	lowLevels.anchorX, lowLevels.anchorY = 0, 0
    lowLevels.x = display.contentWidth * .67
    lowLevels.y = display.contentHeight*.45
    
    midLevels = widget.newButton{
    	label="6 - 8",
    	labelColor = { default = {0,0,255}, over={100,100,250}},
    	defaultFile="Images/button.png",
    	overFile="Images/button-over.png",
    	width=154, height=40,
    	onRelease = function() return levelSelected("medium") end
    }
	midLevels.anchorX, midLevels.anchorY = 0, 0
    midLevels.x = display.contentWidth * .67
    midLevels.y = display.contentHeight*.60
    
    highLevels = widget.newButton{
    	label="9 - 11",
    	labelColor = { default = {255,0,0}, over={100,100,250}},
    	defaultFile="Images/button.png",
    	overFile="Images/button-over.png",
    	width=154, height=40,
    	onRelease = function() return levelSelected("high") end
    }
	highLevels.anchorX, highLevels.anchorY = 0, 0
    highLevels.x = display.contentWidth * .67
    highLevels.y = display.contentHeight*.75
    
    --end creation of levels buttons
    
	local titleText = display.newText( "Options", display.contentWidth * .40, display.contentHeight*.15, "Fonts/Canterbury" ,display.contentHeight * .1)
	titleText:setTextColor{ 0,0,0}
	
	local difficultyText = display.newText( "Difficulty", display.contentWidth * .15, display.contentHeight*.3, "Fonts/Canterbury" ,display.contentHeight * .1)
	difficultyText:setTextColor{ 0,0,0}
	
	local levelsText = display.newText( "Levels", display.contentWidth * .7, display.contentHeight*.3, "Fonts/Canterbury" ,display.contentHeight * .1)
	levelsText:setTextColor{ 0,0,0}
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( selected )	-- the red rectangle behind the difficulty
	group:insert( selected2)    --the red rectangle behind the levels
	group:insert( easyMode )
	group:insert( mediumMode )
	group:insert( hardMode )
	group:insert( lowLevels)
	group:insert( midLevels)
	group:insert( highLevels)
	group:insert( menuBtn )
	group:insert( creditsBtn )
	group:insert( titleText )
	group:insert( difficultyText )
	group:insert( levelsText )
end

-- Called immediately after scene has moved onscreen:
function scene:enter( event )
	local group = self.view
	-- ads.init("admob", "ca-app-pub-9280611113795519/1956905785", adListener)
	-- ads.show("banner", { x=0, y=display.contentHeight - (display.contentHeight * .09) } )
	composer.returnTo = "menu" 
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	local group = self.view
	-- ads.hide()
end

-- If scene's view is removed, scene:destroy() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	if menuBtn then
		menuBtn:removeSelf()
		menuBtn = nil
	end
	if creditsBtn then
		creditsBtn:removeSelf()
		creditsBtn = nil
	end
	if easyMode then
		easyMode:removeSelf()
		easyMode = nil
	end
	if mediumMode then
		mediumMode:removeSelf()
		mediumMode = nil
	end
	if hardMode then
		hardMode:removeSelf()
		hardMode = nil
	end
	if lowLevels then
		lowLevels:removeSelf()
		lowLevels = nil
	end
	if midLevels then
		midLevels:removeSelf()
		midLevels = nil
	end
	if highLevels then
		highLevels:removeSelf()
		highLevels = nil
	end
	--ads.hide()
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