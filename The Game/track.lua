local track = {}
local radians = 180/math.pi  --> precalculate radians
 
--[[
 track.distanceBetween = function ( pos1, pos2 )
         local sqrt = math.sqrt
        if not pos1 or not pos2 then
                return
        end
        if (not pos1.x or not pos1.y or not pos2.x or not pos2.y) then
                return
        end
        local factor = { x = pos2.x - pos1.x, y = pos2.y - pos1.y }
        return sqrt( ( factor.x * factor.x ) + ( factor.y * factor.y ) )
end
 ]]
 
 
track.doFollow = function (follower, target, missileSpeed)
 
        local missileSpeed = follower.speed
      
        -- get distance between follower and target
        local distanceX = target.x - follower.model.x;
        local distanceY = target.y - follower.model.y;
        
        -- get total distance as one number
        local distanceTotal = math.sqrt ( ( distanceX * distanceX ) + ( distanceY * distanceY ) )
        
		if (distanceTotal <500) then 
			-- calculate how much to move
			local moveDistanceX = distanceX / distanceTotal;
			local moveDistanceY = distanceY / distanceTotal;
			
			-- increase current speed
			follower.moveX = (follower.moveX /3 ) + moveDistanceX; 
			follower.moveY = (follower.moveY/3) + moveDistanceY;
			
			-- get total move distance
			local totalmove = math.sqrt(follower.moveX * follower.moveX + follower.moveY * follower.moveY);
			
			-- apply easing
			follower.moveX = missileSpeed*follower.moveX/totalmove;
			follower.moveY = missileSpeed*follower.moveY/totalmove;
			
			-- move follower
			follower.model.x = follower.model.x + follower.moveX;
			follower.model.y = follower.model.y + follower.moveY;
			
			--change sprite
			if (follower.moveY > follower.moveX) then
				if (follower.moveY > 0) then
					follower.model:setSequence("back")
				else	
					follower.model:setSequence("forward")
				end
			elseif (follower.moveX > 0) then
				follower.model:setSequence("right")
			else	
				follower.model:setSequence("left")
			end
			follower.model:play()
		end
        -- !!!!! you got to check if we hit the target - here or in main game logic !!!!!
 
end
return track