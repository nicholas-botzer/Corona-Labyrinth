Chest = {} 
---Sample chest ----
chestData = {
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


function Chest:new (xpos, ypos)
	c = {}   -- create object if user does not provide one
    setmetatable(c, self)
    self.__index = self
	self.pic = display.newSprite(chestSheet, chestData)
	self.pic.x = xpos 
	self.pic.y = ypos 
	self.closed = true 
	self.contents = {} 
    return c
end

function Chest:open(box, cX, cY) 
	if(box.pic.frame == 1) then
		box.pic:setSequence("open") 
		box.pic:play() 
		box.closed = false 
	end
end

function Chest:getX(box) 
	return box.pic.x 
end

function Chest:getY(box) 
	return box.pic.y
end
