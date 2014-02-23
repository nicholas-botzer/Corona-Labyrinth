local LCS = require 'LCS'
require "options"	-- options needed for difficulty variable
require "CreatureClass"

Demon = Creature:extends()

function Demon:init(posX, posY)
	-- Initialize demon's base attributes
	self.health = 50 + 10 * floorsDone
	self.maxHealth = 50 + 10 * floorsDone
	self.damage = 5 + difficulty * 5
	self.armor = 4 + difficulty
	self.speed = 3 + difficulty

	--Declare and set up Sprite Image Sheet and sequence data
	spriteOptions = {	
		height = 64, 
		width = 64, 
		numFrames = 63, 
		sheetContentWidth = 448, 
		sheetContentHeight = 576 
	}
	mySheet = graphics.newImageSheet("Imp-Sprite.png", spriteOptions) 
	sequenceData = {
		{name = "forward", frames={1,2,3,4}, time = 1000, loopCount = 1},
		{name = "right", frames={22,23,24,25}, time = 1000, loopCount = 1}, 
		{name = "back", frames= {15,16,17,18}, time = 1000, loopCount = 1}, 
		{name = "left", frames={8,9,10,11}, time = 1000, loopCount = 1},
		{name = "attackForward", frames={29,30,31,32}, time = 200, loopCount = 1},
		{name = "attackRight", frames={50,51,52,53}, time = 200, loopCount = 1},
		{name = "attackLeft", frames={36,37,38,39}, time = 200, loopCount = 1},
		{name = "attackBack", frames={43,44,45,46}, time = 200, loopCount = 1},
		{name = "death", frames={57,58,59,60,61,62,63,5}, time = 200, loopCount = 1}
	}	
	
	-- Display the new sprite at the coordinates passed
	self.model = display.newSprite(mySheet, sequenceData)
	self.model:setSequence("forward")
	self.model.x = posX
	self.model.y = posY
	
	
	
--[[*****************    Methods    ******************]]--
	
--[[*******************************************************************************
takeDamage(dmg) - reduces the demons health based on the passed dmg value
	the minimum damage that can be taken is set to 1, changes the sprite sequence
	if the demon dies
********************************************************************************]]--
	function Demon:takeDamage(dmg)
		if (dmg > self.armor) then 
			self.health = self.health - (dmg - self.armor)
		else
			self.health = self.health - 1
		end
		
		if (self.health <= 0) then
			self.isDead = true
			self.model:setSequence("death")
			self.model:play()
		end
		return
	end
	
end -- End DemonClass