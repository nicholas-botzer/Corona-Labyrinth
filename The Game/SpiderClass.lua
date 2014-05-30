local LCS = require 'LCS'
require "options"	-- options needed for difficulty variable
require "CreatureClass"

Spider = Creature:extends()

function Spider:init(posX, posY)
	-- Initialize spiders base attributes
	self.health = 30 + 10 * floorsDone
	self.maxHealth = 30 + 10 * floorsDone
	self.damage = 3 + difficulty * 3
	self.armor = -1 + difficulty
	self.speed = 3 + difficulty

	--Declare and set up Sprite Image Sheet and sequence data
	spriteOptions = {	
		height = 64, 
		width = 64, 
		numFrames = 50, 
		sheetContentWidth = 640, 
		sheetContentHeight = 320 
	}
	mySheet = graphics.newImageSheet("Spider-Sprite.png", spriteOptions) 
	sequenceData = {
		{name = "forward", frames={1,5,6,7,8,9,10}, time = 1000, loopCount = 1},
		{name = "right", frames={31,35,36,37,38,39,40}, time = 1000, loopCount = 1}, 
		{name = "back", frames= {21,25,26,27,28,29,30}, time = 1000, loopCount = 1}, 
		{name = "left", frames={11,15,16,17,18,19,20}, time = 1000, loopCount = 1},
		{name = "attackForward", frames={1,2,3,4}, time = 200, loopCount = 1},
		{name = "attackRight", frames={21,22,23,24}, time = 200, loopCount = 1},
		{name = "attackLeft", frames={11,12,13,14}, time = 200, loopCount = 1},
		{name = "attackBack", frames={31,32,33,34}, time = 200, loopCount = 1},
		{name = "death", frames={41,42,43,44}, time = 200, loopCount = 1}
	}	
	
	-- Display the new sprite at the coordinates passed
	self.model = display.newSprite(mySheet, sequenceData)
	self.model:setSequence("forward")
	self.model.x = posX
	self.model.y = posY
	
	
	
--[[*****************    Methods    ******************]]--
	
--[[*******************************************************************************
takeDamage(dmg) - reduces the spiders health based on the passed dmg value
	the minimum damage that can be taken is set to 1, changes the sprite sequence
	if the spider dies
********************************************************************************]]--
	function Spider:takeDamage(dmg)
		if (dmg > self.armor) then 
			self.health = self.health - (dmg - self.armor)
		else
			self.health = self.health - 1
		end
		
		if (self.health <= 0) then
			self.isDead = true
			self.model:setSequence("death")
			self.model:play()
			currentScore = currentScore + (8*difficulty + (floorsDone*2))
			updateScore()
		end
		return
	end
	
end -- End SpiderClass