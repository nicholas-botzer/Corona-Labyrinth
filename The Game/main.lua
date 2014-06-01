-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "storyboard" module
local storyboard = require "storyboard"

-- load menu screen
local rect
holding = {"great sword", "Master's armor"}
inUse = {}

 
storyboard.gotoScene( "menu" )

--Codes the keys for back button functionality 
local function onKeyEvent(event)
	local phase = event.phase
    local keyName = event.keyName 
    
	if ( "back" == keyName and phase == "up" ) then
		storyboard.gotoScene( storyboard.returnTo, "fade", 500 )
		return true	-- indicates successful touch
		
	else 
		return false ; 
	end
end

Runtime:addEventListener( "key", onKeyEvent )