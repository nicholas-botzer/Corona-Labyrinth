local composer = require("composer")
local scene = composer.newScene()
local widget = require "widget"

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function goToMenu( event )
	-- go to menu.lua scene
	composer.gotoScene( "menu", {effect="fade", time=500} )
	floorsDone = 0
	currentScore = 0
	composer.removeScene("level1")
	composer.removeScene("death")
	return true	-- indicates successful touch

end



timer.performWithDelay(1000,decreaseTime,60)
-- Called when the scene's view does not exist:
function scene:create( event )
    local group = self.view
	local deathText = display.newText( "You have died", display.contentWidth*.38, display.contentHeight *.3, native.systemFont, 28 )
	deathText:setTextColor( 255, 0, 0 )
	local timeLimit = 9
	local timeLeft = display.newText(timeLimit, display.contentWidth*.50, display.contentHeight *.4, native.systemFontBold, 24)
	timeLeft:setTextColor(255,0,0)
	
	local scoreText = display.newText("Your Score: "..currentScore, display.contentWidth*.4,display.contentHeight *.5,native.systemFontBold,24)
	scoreText:setTextColor(255,0,0)
	
	local function timerDown()
		timeLimit = timeLimit-1
		timeLeft.text = timeLimit
		if(timeLimit==0)then
			--print("Time Out") -- or do your code for time out
		end
	end
	timer.performWithDelay(1000,timerDown,timeLimit)
	timer.performWithDelay(10000, goToMenu )
	currentScore = 0
	group:insert(deathText)
	group:insert(scoreText)
	group:insert(timeLeft)
        
       
end


-- Called immediately after scene has moved onscreen:
function scene:enter( event )
		local group = self.view	
 
end


-- Called when scene is about to move offscreen:
function scene:exit( event )
     local group = self.view
	 if timeLeft then
		timeLeft:removeSelf()
		timeLeft = nil
	  end
	  

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroy( event )
     local group = self.view
	 
	  if timeLeft then
		timeLeft:removeSelf()
		timeLeft = nil
	  end
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene