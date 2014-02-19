local storyboard = require("storyboard")
local scene = storyboard.newScene()
local widget = require "widget"

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onMenuBtnRelease( event )
	-- go to menu.lua scene
	storyboard.gotoScene( "menu", "fade", 500 )
	storyboard.purgeScene("death")
	return true	-- indicates successful touch

end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
	
	local deathText = display.newText( "You have died", display.contentWidth*.38, display.contentHeight *.3, native.systemFont, 28 )
	deathText:setTextColor( 255, 0, 0 )
	menuBtn = widget.newButton{
		label="Menu",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=30,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn:setReferencePoint( display.CenterReferencePoint )
	menuBtn.x = display.contentWidth * .5
	menuBtn.y = display.contentHeight * .6
	
	group:insert(deathText)
	group:insert(menuBtn)
        
       
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
		local group = self.view	
 
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        
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