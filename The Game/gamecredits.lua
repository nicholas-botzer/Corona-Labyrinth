-----------------------------------------------------------------------------------------
--
-- credits.lua
--
-----------------------------------------------------------------------------------------
require("main") 
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require "widget"

-- declarations
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

--[[
local function scrollListener( event )
	local phase = event.phase
	local direction = event.direction
	if (event.limitReached) then
		if (direction == "up") then
			
		end
	end
	
end
]]

-- 'onRelease' event listener
local function onMenuBtnRelease()
	-- go to menu.lua scene
	storyboard.gotoScene( "menu", "fade", 500 )
	return true	-- indicates successful touch
end
local function onBackBtnRelease()
	-- go to menu.lua scene
	storyboard.gotoScene( "options", "fade", 200 )
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
	local background = display.newImageRect( "optionsScreen.png", display.contentWidth, display.contentHeight )
	background:setFillColor(0,0,0)
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
	
	backBtn = widget.newButton{
		label="Options",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=30,
		onRelease = onBackBtnRelease	-- event listener function
	}
	backBtn:setReferencePoint( display.CenterReferencePoint )
	backBtn.x = display.contentWidth - creditsBtn.width * .5
	backBtn.y = creditsBtn.height * .5


	local scrollableCredits = widget.newScrollView {
		left = 0, top = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		topPadding = screenH * .1,
		bottomPadding = screenH * .1,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false
		--listener = scrollListener,
	}
	
	-- ********************************************
	-- ***              Credits                 ***
	-- ********************************************
	local creditsText = "     Sprites - Author (Licenses):\n"
	creditsText = creditsText .. "Player - Author (Licenses)\n"
	creditsText = creditsText .. "Spider - William.Thompsonj at OpenGameArt.org (CC-BY 3.0, GPL 3.0, GPL 2.0)\n"
	creditsText = creditsText .. "Skeleton - Wulax at OpenGameArt.org (CC-BY-SA 3.0, GPL 3.0)\n"
	creditsText = creditsText .. "Imp - William.Thompsonj at OpenGameArt.org (CC-BY 3.0, GPL 3.0, GPL 2.0)\n"
	creditsText = creditsText .. "Chests - hc at OpenGameArt.org (CC-BY 3.0)\n"
	creditsText = creditsText .. "Stairs - Author (licenses)\n"
	creditsText = creditsText .. "Items - Author (licenses)\n"
	creditsText = creditsText .. "Floors - Tiziana at OpenGameArt.org (CC-BY 3.0, LGPL 3.0, LGPL 2.1)\n"
	creditsText = creditsText .. "Walls - Georges Grondin at OpenGameArt.org (CC-BY-SA 3.0, GPL 3.0, GPL 2.0)\n"
	creditsText = creditsText .. "Inventory Knight Armor - Author (licenses)\n"
	creditsText = creditsText .. "Inventory Sword - Author (licenses)\n"
	
	creditsText = creditsText .. "\n\n     Music - Author (Licenses)\n"
	creditsText = creditsText .. "Mystical Caverns (Menu Music) - MichaelTheCrow on OpenGameArt.org (CC-BY 3.0)\n"
	creditsText = creditsText .. "Battle Escape (Labyrinth Music) - bf5man on OpenGameArt.org (CC-BY 3.0)\n"
	creditsText = creditsText .. "Battle Theme A (Boss Music) - CynicMusic.com (CC-BY 3.0)\n"
	
	creditsText = creditsText .. "\n\n     License Links\n"
	creditsText = creditsText .. "CC-BY 3.0 - http://creativecommons.org/licenses/by/3.0/legalcode \n"
	creditsText = creditsText .. "CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/legalcode \n"
	creditsText = creditsText .. "LGPL 2.1 - http://www.gnu.org/licenses/lgpl-2.1.html \n"
	creditsText = creditsText .. "LGPL 3.0 - http://www.gnu.org/licenses/lgpl-3.0.html \n"
	creditsText = creditsText .. "GPL 2.0 - http://www.gnu.org/licenses/old-licenses/gpl-2.0.html \n"
	creditsText = creditsText .. "GPL 3.0 - http://www.gnu.org/licenses/gpl-3.0.html \n"
	creditsText = creditsText .. "\n"
	-- ********************************************
	-- ***           End of Credits             ***
	-- ********************************************
	
	local creditsTextObject = display.newText(creditsText, 0,0, 800,0, "Arial", 14)
	creditsTextObject:setTextColor(75)
	scrollableCredits:insert(creditsTextObject)
	
	--add to display group
	group:insert(background)
	group:insert(scrollableCredits)
	group:insert(menuBtn)
	group:insert(backBtn)


end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	print("inside credits")
	storyboard.returnTo = "options" 
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
	if creditsBtn then
		creditsBtn:removeSelf()
		creditsBtn = nil
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