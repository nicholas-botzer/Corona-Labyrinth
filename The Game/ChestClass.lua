--[[
This code represents a chest object that can hold many different items. Chests are randomly placed in the dungeon and can be opened by the player 
to receive the objects inside. 
]]

Chest = {} 
Chest.__index = Chest

-- CHEST SPRITE/IMAGE SHEET INFO --
-- All chests use the same sprite sheet -- 
chestData = {
	{name = "close", frames = {1}, time = 1000, loopCount = 1},
	{name = "open", frames={1, 5, 2, 2}, time = 1000, loopCount = 1},
}
	
chestDetails = {	
	height = 32, 
	width = 32, 
	numFrames = 6, 
	sheetContentWidth = 96, 
	sheetContentHeight = 64 
}
	
chestSheet = graphics.newImageSheet("Sprites/chestResize.png", chestDetails) 
--End of sprite declaration -- 

--List of all potential items that may be placed in the chests--  
itemChoices = {"great sword","long sword","Master's sword","potion","strong potion","Master's armor", "grand boots", "standard armor","standard boots",
"standard sword", "leather vest"}

--Function for creation of a new chest (will be called by map generation in Level1.lua--
function Chest.new (xpos, ypos)
	c = {}   -- create object if user does not provide one
    setmetatable(c, Chest)
	c.pic = display.newSprite(chestSheet, chestData)	--Attribute used to access the chests sprite information
	--X and Y coordinates of the chest are stored within the object-- 
	c.pic.x = xpos 
	c.pic.y = ypos 
	c.closed = true 	--Boolean variable to determine whether or not the chest has been opened. All chests begin by being closed--
	c.contents = fill()		--Calls the fill function which will fill the chest object with 1 random item from the possible items--
	return c 	--Return the chest object
end


--[[
Function fill() places one item at random into the chest.
To do so first a "class" of item is chose (sword, armor, potion, or boot). Boots have a 16% chance of being chosen, everything else (swords, armor, potions) have a 28%
Within each class there is a different probability for each item. The better the item the less chance that it is placed in a chest.
All probabilities are documented below
]]
function fill() 
	rand = math.random()*100 --Random number between 0-100. Determines which class of item will be in chest (sword, armor, boot, or potion) 
	if(rand >=0 and rand < 16) then 
		--70% chance of standard boots, 30% for grand boots 
		rand = math.random()*100 
		if(rand >= 30) then 
			item = itemChoices[9] 
		else 
			item = itemChoices[7]
		end
	elseif(rand >= 16 and rand < 44) then 
		--75% chance normal potion is given, 25% for strong potion 
		rand = math.random()*100 
		if(rand >= 75) then 
			item = itemChoices[5]
		else 
			item = itemChoices[4]
		end
	elseif(rand >= 44 and rand < 72) then 
		--Armor percentages: (vest - 45% standard - 35% master's - 20%) 
		rand = math.random()*100 
		if(rand >= 80) then 
			item = itemChoices[6]
		elseif(rand < 80 and rand >= 45) then 
			item = itemChoices[11] 
		else 
			item = itemChoices[8]
		end
	elseif(rand >=72) then 
		--Sword percentages: (standard- 33% , long- 28%, great- 24%, masters- 15%
		rand = math.random()*100
		if(rand >= 85) then 
			item = itemChoices[3] 
		elseif(rand < 85 and rand >= 61) then 
			item = itemChoices[1]
		elseif(rand < 61 and rand >= 33) then 
			item = itemChoices[2]
		else
			item = itemChoices[10]
		end
	end
	return item 
end


--Function open() is called from level1.lua when the player is close enough to open a chest--
function Chest:open() 
	if(self.pic.frame == 1) then	--Only open the chest if it's current frame is the closed chest image
		self.pic:setSequence("open")  --Set the chest to play the opening sprite sequence
		self.pic:play()   	--Play the opening animation
		self.closed = false 	--The chest is now open, so set the boolean value closed to false 
	end
end

-- getContentents() returns the object that was randomly placed in the chest -- 
function Chest:getContents()
	return self.contents
end

--Returns the x position of the chest--
function Chest:getX() 
	return self.pic.x 
end

--Returns the y position of the chest--
function Chest:getY() 
	return self.pic.y
end
