local storyboard = require("storyboard")
local scene = storyboard.newScene()
local widget = require "widget"

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function goToMenu( event )
	-- go to menu.lua scene
	storyboard.gotoScene( "menu", "fade", 500 )
	floorsDone = 0
	currentScore = 0
	storyboard.purgeScene("level1")
	storyboard.purgeScene("death")
	return true	-- indicates successful touch

end



timer.performWithDelay(1000,decreaseTime,60)
-- Called when the scene's view does not exist:
function scene:createScene( event )
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
function scene:enterScene( event )
		local group = self.view	
 
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
     local group = self.view
	 if timeLeft then
		timeLeft:removeSelf()
		timeLeft = nil
	  end
	  

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
     local group = self.view
	 
	  if timeLeft then
		timeLeft:removeSelf()
		timeLeft = nil
	  end
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene