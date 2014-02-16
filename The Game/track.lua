local track = {}

 
 track.changeSprite = function (follower, distX, distY)
	if (math.abs(distY) > math.abs(distX)) then
		if (distY > 0) then
			if (not (follower.model.sequence == "back" or follower.model.sequence == "attackBack")) then
				follower.model:setSequence("back")
			end
		elseif (not (follower.model.sequence == "forward" or follower.model.sequence == "attackForward")) then
			follower.model:setSequence("forward")
		end
	elseif (distX > 0) then
		if (not (follower.model.sequence == "right" or follower.model.sequence == "attackRight")) then
			follower.model:setSequence("right")
		end
	elseif (not (follower.model.sequence == "left" or follower.model.sequence == "attackLeft")) then
		follower.model:setSequence("left")
	end
end


track.attackSprite = function (follower)
	if (follower.model.sequence == "back") then
		follower.model:setSequence("attackBack")
	elseif (follower.model.sequence == "forward") then
		follower.model:setSequence("attackForward")
	elseif (follower.model.sequence == "right") then
		follower.model:setSequence("attackRight")
	elseif (follower.model.sequence == "left") then
		follower.model:setSequence("attackLeft")
	end
end
 
 
track.doFollow = function (follower, target, followSpeed)
	if ( not follower.isDead) then
        local followSpeed = follower.speed
      
        -- get distance between follower and target for X and Y
        local distanceX = target.model.x - follower.model.x;
        local distanceY = target.model.y - follower.model.y;
        
        -- get total distance
        local distanceTotal = math.sqrt ( ( distanceX * distanceX ) + ( distanceY * distanceY ) )
        
		if (distanceTotal < 250 and distanceTotal > 20) then 
			-- calculate how much to move
			local moveDistanceX = distanceX / distanceTotal;
			local moveDistanceY = distanceY / distanceTotal;
			
			-- increase current speed
			follower.moveX = (follower.moveX ) + moveDistanceX; 
			follower.moveY = (follower.moveY ) + moveDistanceY;
			
			-- get total move distance
			local totalmove = math.sqrt(follower.moveX * follower.moveX + follower.moveY * follower.moveY);
			
			-- apply easing
			follower.moveX = followSpeed*follower.moveX/totalmove;
			follower.moveY = followSpeed*follower.moveY/totalmove;
			
			-- move the follower
			follower.model.x = follower.model.x + follower.moveX;
			follower.model.y = follower.model.y + follower.moveY;

			--change sprite
			track.changeSprite(follower, distanceX, distanceY)
			follower.model:play()
		elseif (distanceTotal < 50) then
			--attacking stuff
			track.attackSprite(follower)
			attackPlayer(follower)
			follower.model:play()
		end
		
		--handle knockback
		if (math.abs(follower.knockbackX) > 5) then
			follower.model.x = follower.model.x + follower.knockbackX
			follower.knockbackX = follower.knockbackX * .75
		end
		if (math.abs(follower.knockbackY) > 5) then
			follower.model.y = follower.model.y + follower.knockbackY
			follower.knockbackY = follower.knockbackY * .75
		end
		
		-- play the sprite animation
		
	end
end
return track