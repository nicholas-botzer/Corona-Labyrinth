local LCS = require 'LCS'
local storyboard = require( "storyboard" )
require "options"	-- options needed for difficulty variable

Creature = LCS.class({health, maxHealth, damage, armor, speed, spriteOptions, mySheet ,model, moveX = 0, moveY = 0, knockbackX = 0, knockbackY = 0, isDead})

function Creature:init(posX, posY)
	-- Initialize creatures base attributes
	self.health = 30 + 10 * floorsDone
	self.maxHealth = 30 + 10 * floorsDone
	self.damage = 3 + difficulty * 5 + floorsDone
	self.armor = 1 * difficulty + floorsDone
	self.speed = 2 + difficulty
	self.isDead = false

	--Declare and set up Sprite Image Sheet and sequence data
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
	
	-- Display the new sprite at the coordinates passed
	self.model = display.newSprite(mySheet, sequenceData)
	self.model:setSequence("forward")
	self.model.x = posX
	self.model.y = posY

	
	
--[[*****************    Methods    ******************]]--
	
--[[*******************************************************************************
takeDamage(dmg) - reduces the creatures health based on the passed dmg value
	the minimum damage that can be taken is set to 1, changes the sprite sequence
	if the creature dies
********************************************************************************]]--
	function Creature:takeDamage(dmg)
		if (dmg > self.armor) then 
			self.health = self.health - (dmg - self.armor)
		else
			self.health = self.health - 1
		end
		
		if (self.health <= 0) then
			self.isDead = true
			self.model:setSequence("death")
			self.model:play()
			if ( floorsDone >= 0 ) then
				currentScore = currentScore + (10*difficulty+(floorsDone*2))
				updateScore()
			end
		end
		return
	end


	function Creature:delete()
		self.model:removeSelf()
		self.model = nil
	end
		
end -- End CreatureClass