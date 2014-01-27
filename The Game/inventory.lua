-----------------------------------------------------------------------------------------
--
-- inventory.lua
--
-----------------------------------------------------------------------------------------

require("main")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require "widget"
currentSelection = ""

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

local function snapTo() --Function to implement "snapping" in the drag and drop interface 
	itemName = inBag[currentSelection].sequence 
	item = inBag[currentSelection]

	---SWORD SNAP---
	if string.find(itemName, "sword") then 
		if(math.abs(item.x - selectedSword.x) < 50 and math.abs(item.y - selectedSword.y) < 50) then 
			item.x = selectedSword.x 
			item.y = selectedSword.y
			if(inUse["sword"]) then 
				inUse["sword"].x = inUse["sword"].origX
				inUse["sword"].y = inUse["sword"].origY
				inBag[inUse["sword"].num].equipped = false 
				inUse["sword"] = item
				inUse["sword"].equipped = true
			else
				inUse["sword"] = item
				inUse["sword"].equipped = true
			end
		else
			item.x = item.origX 
			item.y = item.origY
		end
	end
	
	---ARMOR SNAP---
	if string.find(itemName, "armor") then 
		if(math.abs(item.x - selectedArmor.x) < 50 and math.abs(item.y - selectedArmor.y) < 50) then 
			item.x = selectedArmor.x 
			item.y = selectedArmor.y
			if(inUse["armor"]) then 
				inUse["armor"].x = inUse["armor"].origX
				inUse["armor"].y = inUse["armor"].origY
				inBag[inUse["armor"].num].equipped = false 
				inUse["armor"] = item
				inUse["armor"].equipped = true
			else
				inUse["armor"] = item
				inUse["armor"].equipped = true
			end
		else
			item.x = item.origX 
			item.y = item.origY
		end
	end
	
	---BOOT SNAP---
	if string.find(itemName, "boots") then 
		if(math.abs(item.x - selectedBoots.x) < 50 and math.abs(item.y - selectedBoots.y) < 50) then 
			item.x = selectedBoots.x 
			item.y = selectedBoots.y
			if(inUse["boots"]) then 
				inUse["boots"].x = inUse["boots"].origX
				inUse["boots"].y = inUse["boots"].origY
				inBag[inUse["boots"].num].equipped = false 
				inUse["boots"] = item
				inUse["boots"].equipped = true
			else
				inUse["boots"] = item
				inUse["boots"].equipped = true
			end
		else
			item.x = item.origX 
			item.y = item.origY
		end
	end
	
	---POTION SNAP--- 
	if string.find(itemName, "potion") then 
		if(math.abs(item.x - potionSlot.x) < 50 and math.abs(item.y - potionSlot.y) < 50) then 
			inUse["potion"] = inUse["potion"]+1
			if(string.find(itemName, "strong")) then --Add another to counter for a strong potion (strong potion = 2 normal potions)
				inUse["potion"] = inUse["potion"]+1 
			end
			inBag[currentSelection].equipped = true
			item:removeSelf()
		else
			item.x = item.origX 
			item.y = item.origY
		end
	end
end

local function touchHandler(event) 
	num = event.target.num
	display.currentStage:setFocus(event.target) 

	if event.phase == "began" then
		currentSelection = num
		for i=1,table.getn(inBag),1 do 
			if(not i == num) then
				inBag[i]:removeEventListener("touch")
			end
		end
		inBag[num].markX = inBag[num].x    -- store x location of object
		inBag[num].markY = inBag[num].y    -- store y location of object
    elseif event.phase == "moved" then	
		inBag[currentSelection].x = (event.x - event.xStart) + inBag[currentSelection].markX
		inBag[currentSelection].y = (event.y - event.yStart) + inBag[currentSelection].markY
	elseif event.phase == "ended" then 
		snapTo() 
		for i=1,table.getn(inBag),1 do 
			if(not i == currentSelection) then
				inBag[i]:addEventListener("touch", touchHandler)
			end
		end
		display.currentStage:setFocus(nil) 
	end
    
    return true
end

yVal = 5
local function displayInventory()
	for i=inventoried,table.getn(holding)-1,1 do
		if(not inBag[i+1].equipped) then
			multiplier = .08 * (i%5)
			if(i%5 == 0) then 
				yVal = yVal + 51.5 
			end
			inBag[i+1].x = display.contentWidth* (.64 + multiplier) 
			inBag[i+1].y = yVal   -- Start at 85
			inBag[i+1].origX = inBag[i+1].x 
			inBag[i+1].origY = inBag[i+1].y
			inBag[i+1]:addEventListener( "touch", touchHandler )
			group:insert(inBag[i+1]) 
		end
	end
end
	
local function matchItem(item) 		
	table.insert(inBag, display.newSprite(weaponImage, weapons))
	newIndex = table.getn(inBag) 
	inBag[newIndex]:setSequence(item)
	inBag[newIndex].num = newIndex
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
	inUse = {}  --Items currently equipped 
	inUse["sword"] = nil 
	inUse["armor"] = nil 
	inUse["boots"] = nil 	
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
		{name = "long sword", frames = { 39 }},
		{name = "agile sword", frames = { 31 }}, 
		{name = "Master's sword", frames = { 30 }},
		{name = "potion", frames = { 6 }},
		{name = "strong potion", frames = { 3 }},
		{name = "Master's armor", frames = { 58 }}, 
		{name = "Master's leg-armor", frames = { 60 }}, 
		{name = "grand boots", frames = { 61 }}, 
		{name = "standard armor", frames = { 10 }}, 
		{name = "standard boots", frames = { 13 }}, 
		{name = "standard sword", frames = { 38 }},
		{name = "standard leg-armor", frames = { 12 }},
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
	
	--selectedSword = display.newRect(display.contentWidth *.3, sword.y+(sword.height*.5), sword.width*.5, sword.height*.3)
	selectedSword = display.newRect(sword.x+(sword.width*.5), sword.y+(sword.height*.5), 30, 30)
	selectedSword.strokeWidth = 3 
	selectedSword:setStrokeColor(204, 51, 204)
	
	selectedBoots = display.newRect(armor.x+(armor.width*.4), armor.y+armor.height*.9, 30,30)
	selectedBoots.strokeWidth = 3 
	selectedBoots:setStrokeColor(135, 196, 250)
	
	selectedArmor = display.newRect(armor.x+(armor.width*.4), armor.y+armor.height*.1, 30,30)
	selectedArmor.strokeWidth = 3 
	selectedArmor:setStrokeColor( 0, 204, 153)
	
	potionLabel = display.newText("  Place Potion\n  To Consume", selectedSword.x-96, selectedBoots.y)
	potionLabel:setTextColor(0,0,0)
	
	potionSlot = display.newRect(potionLabel.x, potionLabel.y, potionLabel.width, potionLabel.height) 
	potionSlot:setReferencePoint(display.CenterReferencePoint)
	potionSlot.x = potionLabel.x 
	potionSlot.y = potionLabel.y
	potionSlot:setFillColor(229,8,8)

	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( menuBtn )
	group:insert( backBtn )
	group:insert( bag ) 
	group:insert( armor ) 
	group:insert( sword ) 
	group:insert ( selectedSword ) 
	group:insert ( selectedBoots ) 
	group:insert ( selectedArmor ) 
	group:insert ( potionSlot ) 
	group:insert ( potionLabel ) 
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	group = self.view
	inUse["potion"] = 0 
	inventoried = table.getn(inBag) 
	
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