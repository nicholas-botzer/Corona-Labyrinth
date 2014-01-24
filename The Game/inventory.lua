-----------------------------------------------------------------------------------------
--
-- inventory.lua
--
-----------------------------------------------------------------------------------------

require("main")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require "widget"

-- declarations
local backBtn, screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-- 'onRelease' event listener
local function onMenuBtnRelease()
	-- go to menu.lua scene
	storyboard.gotoScene( "menu", "fade", 500 )
	return true	-- indicates successful touch
end

local function onBackBtnRelease()
	storyboard.gotoScene( "level1", "fade", 250 )
	return true	-- indicates successful touch
end

local function displayInventory()
	local yVal = 5
	for i=0,table.getn(inBag)-1,1 do
		multiplier = .08 * (i%5)
		if(i%5 == 0) then 
			yVal = yVal + 51.5 
		end
		inBag[i+1].x = display.contentWidth* (.64 + multiplier) 
		inBag[i+1].y = yVal   -- Start at 85
		group:insert(inBag[i+1]) 
	end
end
	
local function matchItem(item) 		
	table.insert(inBag, display.newSprite(weaponImage, weapons))
	newIndex = table.getn(inBag) 
	inBag[newIndex]:setSequence(item)
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------

function scene:createScene (event)
	group = self.view
	inBag = {}   --items in players bag (holding[] elements are converted from strings to their respective sprite when placed into inBag
	--Declaration of Inventory Images 
	weaponSettings =  {
		height = 32, 
		width = 32,
		numFrames = 64, 
		sheetContentWidth = 256, 
		sheetContentHeight = 256 
	}

	weapons = { 
		{name = "great sword", frames = { 52 }},
		{name = "onyx sword", frames = { 39 }},
		{name = "agile sword", frames = { 31 }}, 
		{name = "Master's sword", frames = { 30 }},
		{name = "potion", frames = { 6 }},
		{name = "strong potion", frames = { 3 }},
		{name = "Master's armor", frames = { 58 }}, 
		{name = "Master's leg-armor", frames = { 60 }}, 
		{name = "grand boots", frames = { 61 }}, 
	}
	
	weaponImage = graphics.newImageSheet("icons2.png", weaponSettings)
	
	---End Inventory Image declarations 
	
	-- create a grey rectangle as the backdrop
	local background = display.newImageRect( "invScreen.png", display.contentWidth, display.contentHeight )
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
	
	backBtn = widget.newButton{
		label="Back",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=30,
		onRelease = onBackBtnRelease	-- event listener function
	}
	backBtn:setReferencePoint( display.CenterReferencePoint )
	backBtn.x = backBtn.width *.5 
	backBtn.y = menuBtn.height * .5 
	
	menuBtn:setReferencePoint( display.CenterReferencePoint )
	menuBtn.x = display.contentWidth - menuBtn.width * .5 
	menuBtn.y = menuBtn.height * .5
	
	local bag = display.newImageRect("tiles2.png", display.contentWidth*.4, display.contentHeight-(menuBtn.height*2))  
	bag:setReferencePoint(display.TopLeftReferencePoint)
	bag.x = display.contentWidth*.6
	bag.y = menuBtn.y + menuBtn.height*.5
	
	--sword.png
	local armor = display.newImageRect("knightBW.png", display.contentWidth*.2, display.contentHeight-(menuBtn.height*4)) 
	armor:setReferencePoint(display.TopLeftReferencePoint) 
	armor.x = 0 
	armor.y = menuBtn.y + menuBtn.height
	
	local sword = display.newImageRect("swordWhite.png", display.contentWidth*.2, display.contentHeight-(menuBtn.height*4)) 
	sword:setReferencePoint(display.TopLeftReferencePoint) 
	sword.x = display.contentWidth*.3 
	sword.y = menuBtn.y + menuBtn.height 
	
	--[[
	local titleText = display.newText( "Bag Contents", display.contentWidth - (bag.width*.5), 40, "Canterbury" , 20)
	titleText:setReferencePoint(CenterReferencePoint)
	titleText.x = display.contentWidth - (bag.width*.5)
	--titleText:setTextColor{ 0,0,0}
	]]
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( menuBtn )
	group:insert( backBtn )
	group:insert( bag ) 
	group:insert( armor ) 
	group:insert( sword ) 
	--group:insert( titleText )
	
	for i=1, table.getn(holding), 1 do 
		matchItem( holding[i] ) 
	end
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	group = self.view
	for i=table.getn(inBag), table.getn(holding)-1, 1 do 
		matchItem( holding[i+1] ) 
	end

	displayInventory() 
	storyboard.returnTo = "level1"
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
	if backBtn then
		backBtn:removeSelf()
		backBtn = nil
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