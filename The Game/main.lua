-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "storyboard" module
local composer = require "composer"
composer.gotoScene( "menu" )

-- load menu screen
local rect
holding = {}
inUse = {}

 


--Codes the keys for back button functionality 
local function onKeyEvent(event)
	local phase = event.phase
    local keyName = event.keyName 
    
	if ( "back" == keyName and phase == "up" ) then
		composer.gotoScene( composer.returnTo, {effect="fade", time=500} )
		return true	-- indicates successful touch
		
	else 
		return false ; 
	end
end

Runtime:addEventListener( "key", onKeyEvent )