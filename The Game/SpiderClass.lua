local LCS = require 'LCS'
require "options"
require "CreatureClass"

Spider = Creature:extends()

function Spider:init(posX, posY)
		self.health = 30 + 10 * floorsDone
		self.maxHealth = 30 + 10 * floorsDone
		self.damage = 3 + difficulty * 3
		self.armor = -1 + difficulty
		self.speed = 3 + difficulty
	
		--Declare Image Sheet 
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
			{name = "death", frames={41,42,43,44,45}, time = 200, loopCount = 1}
		}	
	
		self.model = display.newSprite(mySheet, sequenceData)
		self.model:setSequence("forward")
		self.model.x = posX
		self.model.y = posY
	
	function Spider:takeDamage(dmg)
		if (dmg > self.armor) then 
			self.health = self.health - (dmg - self.armor)
		else
			self.health = self.health - 1
		end
		
		if (self.health <= 0) then
			self.model:setSequence("death")
			self.model:play()
		end
		return
	end
	
end