-----------------------------------------------------------------------------------------
--
-- inventory.lua
--
-----------------------------------------------------------------------------------------
--[[
This file handles the interaction of chests, items, and player stats. 
Items that are recovered from chests are displayed onto the screen in the inventory screen. 
The user then may place items from the inventory onto the player in order to improve the player's stats.
Most code here is handled through arrays that can be accessed in both level1.lua and inventory (via main.lua) 
]]

--Necessary requirements
require("main")
local composer = require( "composer" )
local scene = composer.newScene()
local widget = require "widget"
--local ads = require("ads")
currentSelection = nil
--End of requires 

-- declarations
local backBtn, screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-- 'onRelease' event listener
--Takes the user to the menu screen
local function onMenuBtnRelease()
	local previousScene = composer.getSceneName( "previous" )
	-- go to menu.lua scene
	composer.gotoScene( "menu", {effect="fade", time=500} )
	return true	-- indicates successful touch
end
--End menu button function

--Handles back button event
local function onBackBtnRelease()
	local previousScene = composer.getSceneName( "previous" )
	composer.gotoScene( previousScene, {effect="fade", time=250} )
	return true	-- indicates successful touch
end
--End of back button code

--Code to handle the snap into functionality for placing an item image onto the player model/sword layout
--Code detects if an image is close to its appropriate slot or not. 
--If the item is close enough it snaps into the square, if not it goes back into the the players unused inventory
local function snapTo() 
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
				inUse["sword"].new = true 
			else
				inUse["sword"] = item
				inUse["sword"].equipped = true
			end
			if string.find(itemName, "standard") then 
				inUse["sword"].modifier = 5
				rect.damage = rect.baseDamage + 5
			elseif string.find(itemName, "long") then
				inUse["sword"].modifier = 8
				rect.damage = rect.baseDamage + 8
			elseif string.find(itemName, "great") then 
				inUse["sword"].modifier = 13 
				rect.damage = rect.baseDamage + 13
			elseif string.find(itemName, "Master") then 
				inUse["sword"].modifier = 18 
				rect.damage = rect.baseDamage + 18
			end
			dmgText.text = "Damage: "..rect.damage
			currentSelection = nil
			modifyText:removeSelf() --Removes the text displaying the previous items modification stats 
			modifyText = nil 
		else
			item.x = item.origX 
			item.y = item.origY
		end
	end
	
	---ARMOR SNAP---
	if string.find(itemName, "armor") or string.find(itemName, "vest") then 
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
			if string.find(itemName, "vest") then
				inUse["armor"].modifier = 5
				rect.armor = rect.baseArmor + 5
			elseif string.find(itemName, "standard") then 
				inUse["armor"].modifier = 10 
				rect.armor = rect.baseArmor + 10
			elseif string.find(itemName, "Master") then 
				inUse["armor"].modifier = 15 
				rect.armor = rect.baseArmor + 15
			end
			armorText.text = "Armor: "..rect.armor
			currentSelection = nil
			modifyText:removeSelf() --Removes the text displaying the previous items modification stats 
			modifyText = nil 
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
			if string.find(itemName, "standard") then
				inUse["boots"].modifier = 2
				rect.speed = rect.baseSpeed + 2
			elseif string.find(itemName, "grand") then 
				rect.speed = rect.baseSpeed + 3
				inUse["boots"].modifier = 3
			end
			bootText.text = "Speed: "..rect.speed
			currentSelection = nil
			modifyText:removeSelf() --Removes the text displaying the previous items modification stats 
			modifyText = nil 
		else
			item.x = item.origX 
			item.y = item.origY
		end
	end
	
	---POTION SNAP--- 
	if string.find(itemName, "potion") then 
		if(math.abs(item.x - potionSlot.x) < 50 and math.abs(item.y - potionSlot.y) < 50) then 
			rect.health = rect.health + 20
			if(string.find(itemName, "strong")) then --Add another to counter for a strong potion (strong potion = 2 normal potions)
				rect.health = rect.health + 20
			end
			if(rect.health > 100) then  --Don't allow health to exceed 100
				rect.health = 100 
			end
			inBag[currentSelection].equipped = true
			item:removeSelf()
			currentSelection = nil
			modifyText:removeSelf() --Removes the text displaying the previous items modification stats 
			modifyText = nil 
		else
			item.x = item.origX 
			item.y = item.origY
		end
	end
end
-------------------------------------
----End of snap to function----------
-------------------------------------

--Display Modifier displays how the currently clicked item will effect the player's stats 
--The text stays up as long as the player is touching the item's image. When released the text should be destroyed
local function displayModifier(item)
	--Location and attributes for the text are declared first
	modifyText = display.newText("", display.contentWidth*.5, display.contentHeight*.35, native.systemFont, 15)
	local diff = 0
	
	--Determine which item is selected out of the possible items 
	--Each item's modification text is hard coded 
	
	---SWORD Text---
	if string.find(item, "sword") then 
		diff =  rect.baseDamage - rect.damage
		if string.find(item, "standard") then 
			diff = diff + 5
		elseif string.find(item, "long") then
			diff = diff + 8
		elseif string.find(item, "great") then 
			diff = diff + 13
		elseif string.find(item, "Master") then 
			diff = diff + 18
		end
		if(diff > 0) then
			modifyText.text = "Damage +"..diff
		else
			modifyText.text = "Damage "..diff
		end
	end
	
	---ARMOR Text---
	if string.find(item, "armor") or string.find(item, "vest") then 
		diff =  rect.baseArmor - rect.armor
		if string.find(item, "vest") then
			diff = diff + 5
		elseif string.find(item, "standard") then 
			diff = diff + 10
		elseif string.find(item, "Master") then 
			diff = diff + 15
		end
		if(diff > 0) then
			modifyText.text = "Armor +"..diff
		else
			modifyText.text = "Armor "..diff
		end
	end
	
	---BOOT Text---
	if string.find(item, "boots") then 
		diff = rect.baseSpeed - rect.speed
		if string.find(item, "standard") then
			diff = diff + 2
		elseif string.find(item, "grand") then 
			diff = diff + 3
		end
		if(diff > 0) then
			modifyText.text = "Speed +"..diff
		else
			modifyText.text = "Speed "..diff
		end
	end
	
	---POTION Text--- 
	if string.find(item, "potion") then 
		if string.find(item, "strong") then
			modifyText.text = "Heals 40 HP"
		else
			modifyText.text = "Heals 20 HP"
		end
	end 
	modifyText:setTextColor(200,180,0) 	--Sets the text color to gold
end 
-----------------------------------------
---End of modification text function-----
-----------------------------------------

local function placeItem(event)
	if event.phase == "began" then
		if(currentSelection) then
			inBag[currentSelection].x = event.x
			inBag[currentSelection].y = event.y 
			snapTo()
		end
	end
	return true
end

--Handles the drag and drop functionality of item images--
local function touchHandler(event) 
	if(not event.target.equipped) then  --Only allows non-equipped items to be dragged 
		num = event.target.num			--Gets the id of the item (ids are given when items are first displayed in the inventory screen)
		display.currentStage:setFocus(event.target) --Ensures that no other item's touch handler will be activated during the handling of this item
													--Without setFocus it would be possible to "lose" the dragging item by moving your finger too fast
													--Set focus makes this object the focus for all future touch events (until focus is released) 		
		if event.phase == "began" then  
			if modifyText then
				modifyText:removeSelf()
				modifyText = nil 
			end
			currentSelection = num			--Current Selection refers to the item that is currently being moved -> it is set to the item's id (num)
			--Cycles through every item currently displayed in the inventory screen and removes their touch
			--Handlers so that they aren't accidentally fired off during the handling of the current items touch event
			--This combined with the focus being set on the item clicked will insure that no other item is moved or even detects a touch during the course of 
			--the selected items dragging. 
			for i=1,table.getn(inBag),1 do  
				if(not i == num) then
					inBag[i]:removeEventListener("touch")
				end
			end
		displayModifier(inBag[currentSelection].sequence) --Calls displayModifier() to show the user what the currently selected items stats are 
		
		--Moves the item across the screen following the user's finger (drag) whose coordinate position comes in as event.x and event.y
		elseif event.phase == "moved" then	
			inBag[currentSelection].x = (event.x - event.xStart) + inBag[currentSelection].origX
			inBag[currentSelection].y = (event.y - event.yStart) + inBag[currentSelection].origY
			
		elseif event.phase == "ended" then  --Dragging event has ended (user lifted finger from screen)
			snapTo() 	--Snap the item to where it should go based on snapTo() -Either onto the player or bag into the inventory "bag" 
			for i=1,table.getn(inBag),1 do  --For loop restores the touch listeners back to all the items
				if(not i == currentSelection) then
					inBag[i]:addEventListener("touch", touchHandler)
				end
			end
			display.currentStage:setFocus(nil)  --Frees the scene's focus 
		end
		return true
    end 
end
----------------------------------------------------
----End of drag and drop handler (touch handler)----
----------------------------------------------------

--The following function handles the display of items into the inventory "bag"--
--Items are placed in the center a background image that is tiled - that is where the increments for x and y come from-- 
--Each item is then given a touch handler so that it can be dragged and dropped, in order to be equipped--
yVal = 5
local function displayInventory()
	--Inventoried is the count of items that have already been displayed, holding is the array that holds all items the player owns--
	--The for loop goes through newly acquired items (through chests since the last time the user entered the inventory screen) and displays the--
	--new items
	for i=inventoried,table.getn(holding)-1,1 do
		if(not inBag[i+1].equipped) then
			multiplier = .08 * (i%5)  --Works to place each item roughly in the middle of a tile of the background image
			if(i%5 == 0) then 	--Loops back to the first column when the last column has been passed 
				yVal = yVal + 51.5 		--Roughly gets each items y-axis aligned to the center of a tile
			end
			inBag[i+1].x = display.contentWidth* (.64 + multiplier)  --Determines the x value for the item
			inBag[i+1].y = yVal   --Determines the y-value for the item (starts at 85)
			inBag[i+1].origX = inBag[i+1].x 	--Original x position of the item (used in snapTo())
			inBag[i+1].origY = inBag[i+1].y		--Original Y position of the item (used in snapTo())
			inBag[i+1]:addEventListener( "touch", touchHandler ) --Adds a touch handler to the image (allows it to be interacted with by user)
			group:insert(inBag[i+1]) 	--Inserts the image into the display group (on the very top so it appears on top of the background tiles)
		end
	end
end
---------------------------------------
------End of display function----------
---------------------------------------

---------------------------------------
--Match Item gives each item the player has collected an unique ID and places it in the user's "bag"
--The bag is what is interacted with in other inventory routines
---------------------------------------
local function matchItem(item) 		
	table.insert(inBag, display.newSprite(weaponImage, weapons))
	newIndex = table.getn(inBag) 
	inBag[newIndex]:setSequence(item)
	inBag[newIndex].num = newIndex
end
---------------------------------
---------End Match Item----------
---------------------------------

--Display user's current modified stats
local function displayStats()
	dmgText = display.newText("Damage: "..rect.damage, display.contentWidth*.45, display.contentHeight*.15, native.systemFont, 15)
	dmgText:setTextColor(0,0,0)
	
	armorText = display.newText("Armor: "..rect.armor, display.contentWidth*.45, display.contentHeight*.20, native.systemFont, 15)
	armorText:setTextColor(0,0,0)
	
	bootText = display.newText("Speed: "..rect.speed, display.contentWidth*.45, display.contentHeight*.25, native.systemFont, 15)
	bootText:setTextColor(0,0,0)
	
	group:insert(dmgText)
	group:insert(armorText)
	group:insert(bootText)
end

function scene:create (event)
	group = self.view
	inBag = {}   --items in players bag (holding[] elements are converted from strings to their respective sprite when placed into inBag
	inUse = {}  --Items currently equipped 
	--Set equipped item values to nil to begin with (nothing is equipped to start the game) 
	inUse["sword"] = nil 
	inUse["armor"] = nil 
	inUse["boots"] = nil 
	inUse["potion"] = 0 
	
	---------------------------------
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
		{name = "Master's leg-mail", frames = { 60 }}, 
		{name = "grand boots", frames = { 61 }}, 
		{name = "standard armor", frames = { 10 }}, 
		{name = "standard boots", frames = { 13 }}, 
		{name = "standard sword", frames = { 38 }},
		{name = "standard leg-mail", frames = { 12 }},
		{name = "leather vest", frames = { 32 }},
	}
	
	weaponImage = graphics.newImageSheet("icons2.png", weaponSettings)
	--------------------------------------
	---End Inventory Image declarations 
	--------------------------------------
	
	-- create a grey rectangle as the backdrop
	local background = display.newImageRect( "optionsScreen.png", display.contentWidth, display.contentHeight )
	background.anchorX, background.anchorY = 0, 0
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
	menuBtn.x = display.contentWidth - menuBtn.width * .5 
	menuBtn.y = menuBtn.height * .5
	
	backBtn = widget.newButton{
		label="Back",
		labelColor = { default = {255}, over= {128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=30,
		onRelease = onBackBtnRelease	-- event listener function
	}
	backBtn.x = backBtn.width *.5 
	backBtn.y = menuBtn.height * .5 
	
	
	
	-------Displays various icons on the screen with which the player is given reference points to interact with later---------
	local bag = display.newImageRect("tiles2.png", display.contentWidth*.4, display.contentHeight-(menuBtn.height*2))  
	bag.anchorX, bag.anchorY = 0, 0
	bag.x = display.contentWidth*.6
	bag.y = menuBtn.y + menuBtn.height*.5
	
	--sword.png
	local armor = display.newImageRect("armored.png", display.contentWidth*.2, display.contentHeight-(menuBtn.height*4)) 
	armor.anchorX, armor.anchorY = 0, 0
	armor.x = 0 
	armor.y = menuBtn.y + menuBtn.height
	
	local sword = display.newImageRect("swordWhite.png", display.contentWidth*.2, display.contentHeight-(menuBtn.height*4)) 
	sword.anchorX, sword.anchorY = 0, 0
	sword.x = display.contentWidth*.2	
	sword.y = menuBtn.y + menuBtn.height 
	
	selectedSword = display.newRect(sword.x+(sword.width*.5), sword.y+(sword.height*.5), 30, 30)
	selectedSword.strokeWidth = 3 
	selectedSword:setStrokeColor(204, 51, 204)
	selectedSword:addEventListener("touch", placeItem)
	
	selectedBoots = display.newRect(armor.x+(armor.width*.4), armor.y+armor.height*.8, 30,30)
	selectedBoots.strokeWidth = 3 
	selectedBoots:setStrokeColor(135, 196, 250)
	selectedBoots:addEventListener("touch", placeItem)
	
	selectedArmor = display.newRect(armor.x+(armor.width*.4), armor.y+armor.height*.2, 30,30)
	selectedArmor.strokeWidth = 3 
	selectedArmor:setStrokeColor( 0, 204, 153)
	selectedArmor:addEventListener("touch", placeItem)
	
	potionLabel = display.newText("  Place Potion\n  To Consume", sword.x, selectedBoots.y, native.systemFont, 12)
	potionLabel:setTextColor(0,0,0)
	
	potionSlot = display.newRect(potionLabel.x, potionLabel.y, potionLabel.width, potionLabel.height) 
	potionSlot.x = potionLabel.x 
	potionSlot.y = potionLabel.y
	potionSlot:setFillColor(229,8,8)
	potionSlot:addEventListener("touch", placeItem)
	------------End of display set up------------------

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
function scene:enter( event )
	--Ad stuff
	-- ads.init("admob", "ca-app-pub-9280611113795519/1200026186")
	-- ads.show("banner", { x=0, y=display.contentHeight - (display.contentHeight * .09) } )
	
	--When the scene is entered only items that have been found since the last time should be processed 
	--Any new items need to be displayed and given an ID 
	group = self.view
	inventoried = table.getn(inBag) 
	
	for i=table.getn(inBag), table.getn(holding)-1, 1 do 
		matchItem( holding[i+1] ) 
	end
	
	displayInventory()
	displayStats()
	composer.returnTo = composer.getPrevious()
end

-- Called when scene is about to move offscreen:
function scene:exit( event )
	if(modifyText) then 
		modifyText:removeSelf() 
		modifyText = nil 
	end
	dmgText:removeSelf()
	armorText:removeSelf()
	bootText:removeSelf()
	local group = self.view
	--ads.hide()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
--Inventory screen is only purged in game ending situations (all items should be wiped from existence)
function scene:destroy( event )
	holding = {}  --Game is over player isn't holding any items anymore
	inUse = {}  --No items are in use, since the game is over
	inBag = {}  --No items are in the player's "bag"
	
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

-----------------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene