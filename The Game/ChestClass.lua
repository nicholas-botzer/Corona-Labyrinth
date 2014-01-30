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
	c.contents = itemChoices[rand] 
    return c
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
