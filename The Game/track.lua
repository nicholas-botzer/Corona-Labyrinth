local track = {}

 
 track.changeSprite = function (follower)
	if (math.abs(follower.moveY) > math.abs(follower.moveX)) then
		if (follower.moveY > 0) then
			if (not (follower.model.sequence == "back" or follower.model.sequence == "attackBack")) then
				follower.model:setSequence("back")
			end
		elseif (not (follower.model.sequence == "forward" or follower.model.sequence == "attackForward")) then
			follower.model:setSequence("forward")
		end
	elseif (follower.moveX > 0) then
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
	else
		follower.model:setSequence("attackLeft")
	end
	follower.model:play()
end
 
 
track.doFollow = function (follower, target, missileSpeed)
 
        local missileSpeed = follower.speed
      
        -- get distance between follower and target
        local distanceX = target.x - follower.model.x;
        local distanceY = target.y - follower.model.y;
        
        -- get total distance as one number
        local distanceTotal = math.sqrt ( ( distanceX * distanceX ) + ( distanceY * distanceY ) )
        
		if (distanceTotal < 2500 and distanceTotal > 30) then 
			-- calculate how much to move
			local moveDistanceX = distanceX / distanceTotal;
			local moveDistanceY = distanceY / distanceTotal;
			
			-- increase current speed
			follower.moveX = (follower.moveX /2 ) + moveDistanceX; 
			follower.moveY = (follower.moveY/2) + moveDistanceY;
			
			-- get total move distance
			local totalmove = math.sqrt(follower.moveX * follower.moveX + follower.moveY * follower.moveY);
			
			-- apply easing
			follower.moveX = missileSpeed*follower.moveX/totalmove;
			follower.moveY = missileSpeed*follower.moveY/totalmove;
			
			-- move follower
			follower.model.x = follower.model.x + follower.moveX;
			follower.model.y = follower.model.y + follower.moveY;
			
			--change sprite
			track.changeSprite(follower)
		else
			--attacking stuff
			track.attackSprite(follower)
			attackPlayer(follower)

		end
		
		-- play the sprite animation
		follower.model:play()
        -- !!!!! you got to check if we hit the target - here or in main game logic !!!!!
 
end
return track