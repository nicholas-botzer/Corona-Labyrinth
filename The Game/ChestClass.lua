Chest = {} 

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

function Chest:new (xpos, ypos)
	c = {}   -- create object if user does not provide one
    setmetatable(c, self)
    self.__index = self
	self.pic = display.newSprite(chestSheet, chestData)
	self.pic.x = xpos 
	self.pic.y = ypos 
	self.closed = true 
	self.contents = nil
	generateContents(self) 
    return c
end

function Chest:open(box) 
	if(box.pic.frame == 1) then
		box.pic:setSequence("open") 
		box.pic:play() 
		box.closed = false 
	end
end

function generateContents(box) 
	--Generate random item for the box here
	rand = math.random(11) 
	box.contents = itemChoices[rand] 
end

function Chest:getContents(box)
	return box.contents
end

function Chest:getX(box) 
	return box.pic.x 
end

function Chest:getY(box) 
	return box.pic.y
end
