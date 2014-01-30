local LCS = require 'LCS'
require "options"
require "CreatureClass"

Player = Creature:extends()

function Player:init(posX, posY)
		self.health = 100
		self.maxHealth = 100
		self.damage = 10
		self.armor = 1
		self.speed = 5
	
		--Declare Image Sheet 
		spriteOptions = {	
			height = 32, 
			width = 24, 
			numFrames = 12, 
			sheetContentWidth = 72, 
			sheetContentHeight = 128 
		}
		mySheet = graphics.newImageSheet("knight3.png", spriteOptions) 
		sequenceData = {
			{name = "forward", frames={1,2,3,3}, time = 1000, loopCount = 1},
			{name = "right", frames={4,5,6,6}, time = 1000, loopCount = 1}, 
			{name = "back", frames= {7,8,9,9}, time = 1000, loopCount = 1}, 
			{name = "left", frames={10,11,12,12}, time = 1000, loopCount = 1},
			{name = "attackForward", frames={3,1,3}, time = 200, loopCount = 1},
			{name = "attackRight", frames={6,7,6}, time = 200, loopCount = 1},
			{name = "attackLeft", frames={11,12,12}, time = 200, loopCount = 1},
			{name = "attackBack", frames={8,10,8}, time = 200, loopCount = 1},
		}	
	
		self.model = display.newSprite(mySheet, sequenceData)
		self.model:setSequence("forward")
		self.model.x = posX
		self.model.y = posY
		
		
		
	local function pickAnimation()
		facing = self.rect.model.sequence 
		if(facing == "forward") then 
			self.rect.model:setSequence("attackForward")
		elseif(facing == "right") then 
			self.rect.model:setSequence("attackRight") 
		elseif(facing == "back") then
			self.rect.model:setSequence("attackBack") 
		elseif(facing == "left") then
			self.rect.model:setSequence("attackLeft") 
		end
	end
	
end