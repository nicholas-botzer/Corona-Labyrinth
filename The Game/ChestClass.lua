Chest = {} 
Chest.__index = Chest

-- CHEST SPRITE/IMAGE SHEET INFO --
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
	
chestSheet = graphics.newImageSheet("chestResize.png", chestDetails) 

itemChoices = {"great sword","long sword","Master's sword","potion","strong potion","Master's armor", "grand boots", "standard armor","standard boots",
"standard sword", "leather vest"}

-- END OF IMAGE SHEET DECLARATIONS/SETUP -- 

function Chest.new (xpos, ypos)
	c = {}   -- create object if user does not provide one
    setmetatable(c, Chest)
	c.pic = display.newSprite(chestSheet, chestData)
	c.pic.x = xpos 
	c.pic.y = ypos 
	c.closed = true 
	rand = math.random(11) 
	c.contents = fill()
	return c
end

function fill() 
	rand = math.random()*100 --Random number between 0-100. Determines which class of item will be in chest (sword, armor, boot, or potion) 
	--25% chance of each class being chosen 
	if(rand >=0 and rand < 25) then 
		--70% chance of standard boots, 30% for grand boots 
		rand = math.random()*100 
		if(rand >= 30) then 
			item = itemChoices[9] 
		else 
			item = itemChoices[7]
		end
	elseif(rand >= 25 and rand < 50) then 
		--75% chance normal potion is given, 25% for strong potion 
		rand = math.random()*100 
		if(rand >= 75) then 
			item = itemChoices[5]
		else 
			item = itemChoices[4]
		end
	elseif(rand >= 50 and rand < 75) then 
		--Armor percentages: (vest - 45% standard - 35% master's - 20%) 
		rand = math.random()*100 
		if(rand >= 80) then 
			item = itemChoices[6]
		elseif(rand < 80 and rand >= 45) then 
			item = itemChoices[11] 
		else 
			item = itemChoices[8]
		end
	elseif(rand >=75) then 
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
function Chest:open() 
	if(self.pic.frame == 1) then
		self.pic:setSequence("open") 
		self.pic:play() 
		self.closed = false 
	end
end

function Chest:getContents()
	return self.contents
end

function Chest:getX() 
	return self.pic.x 
end

function Chest:getY() 
	return self.pic.y
end
