local LCS = require 'LCS'
require "options"

Creature = LCS.class({health, maxHealth, damage, armor, speed, spriteOptions, mySheet ,model, moveX = 0, moveY = 0, knockbackX = 0, knockbackY = 0})

function Creature:init(posX, posY)
	self.health = 30 + 10 * floorsDone
	self.maxHealth = 30 + 10 * floorsDone
	self.damage = 3 + difficulty * 3
	self.armor = 1 * difficulty
	self.speed = 2 + difficulty

	--Declare Image Sheet 
	spriteOptions = {	
		height = 64, 
		width = 64, 
		numFrames = 273, 
		sheetContentWidth = 832, 
		sheetContentHeight = 1344 
	}
	mySheet = graphics.newImageSheet("skeleton_3.png", spriteOptions, 50, 50)
	sequenceData = {
		{name = "forward", frames={105,106,107,108,109,110,111,112}, time = 500, loopCount = 1},
		{name = "right", frames={144,145,146,147,148,149,150,151,152}, time = 500, loopCount = 1}, 
		{name = "back", frames= {131,132,133,134,135,136,137,138,139}, time = 500, loopCount = 1}, 
		{name = "left", frames={118,119,120,121,122,123,124,125,126}, time = 500, loopCount = 1},
		{name = "attackForward", frames={157,158,159,160,161,162}, time = 700, loopCount = 0},
		{name = "attackRight", frames={196,197,198,199,200,201}, time = 700, loopCount = 0},
		{name = "attackBack", frames={183,184,185,186,187,188}, time = 700, loopCount = 0},
		{name = "attackLeft", frames={170,171,172,173,174,175}, time = 700, loopCount = 0},
		{name = "death", frames={261,262,263,264,265,266}, time = 500, loopCount = 1}
	}	

	self.model = display.newSprite(mySheet, sequenceData)
	self.model:setSequence("forward")
	self.model.x = posX
	self.model.y = posY


	function Creature:takeDamage(dmg)
		self.health = self.health - (dmg - self.armor)
		if (self.health <= 0) then
			self.model:setSequence("death")
			self.model:play()
		end
		return
	end

	function Creature:delete()
		model:removeSelf()
		model = nil
	end
		
end