module (..., package.seeall)
 
--[[
----------------------------------------------------------------
ANALOG STICK MODULE FOR CORONA SDK
----------------------------------------------------------------
PRODUCT  :              ANALOG STICK MODULE FOR CORONA SDK
VERSION  :              1.0.1
AUTHOR   :              X-PRESSIVE.COM / MIKE DOGAN GAMES & ENTERTAINMENT
WEB SITE :              www.x-pressive.com
SUPPORT  :              support@x-pressive.com
PUBLISHER:              X-PRESSIVE.COM
COPYRIGHT:              (C)2011 X-PRESSIVE.COM / MIKE DOGAN GAMES & ENTERTAINMENT
 
 
----------------------------------------------------------------
USAGE:
----------------------------------------------------------------
1.  INCLUDE THE MODULE:
        StickLib = require("lib_analog_stick")
 
2.  CREATE A STICK (RETURNS A DISPLAY GROUP HANDLE):
        MyStick = StickLib.NewStick( 
                {
                x             = [X-COORD],
                y             = [Y-COORD],
                thumbSize     = [THUMB  SIZE],
                borderSize    = [BORDER SIZE], 
                snapBackSpeed = [THUMB SNAP BACK SPEED 0.0 - 1.0], 
                R             = [COLOR RED   0 - 255],
                G             = [COLOR GREEN 0 - 255],
                B             = [COLOR BLUE  0 - 255],
                } )
 
3.  TO MOVE AN OBJECT:  
        MyStick:move( ObjectHandle, maxSpeed, rotate = true | false)
 
        OR GET STICK INFO TO MOVE ANY OBJECT MANUALLY:
        MyStick:getAngle   () - RETURNS THE CURRENT ANGLE (DIRECTION) FROM 0 (TOP) TO 360 (CLOCKWISE)
        MyStick:getDistance() - RETURNS DISTANCE FROM THUMB TO CENTER IN PIXELS
        MyStick:getPercent () - RETURNS DISTANCE FROM THUMB TO CENTER (NORMALIZED, 0.0 - 1.0)
        
4.  REMOVE STICK
        MyStick:delete()
        MyStick = nil
 
----------------------------------------------------------------
]]--
 
local Pi    = math.pi
local Sqr   = math.sqrt
local Rad   = math.rad
local Sin   = math.sin
local Cos   = math.cos
local Ceil  = math.ceil
local Atan2 = math.atan2
 
----------------------------------------------------------------
-- FUNCTION: CREATE 
----------------------------------------------------------------
function NewStick( Props )
 
        local Group         = display.newGroup()
        Group.x             = Props.x
        Group.y             = Props.y
        Group.Timer                     = nil
        Group.angle                     = 0
        Group.distance          = 0
        Group.percent           = 0
        Group.maxDist           = Props.borderSize
        Group.snapBackSpeed = Props.snapBackSpeed ~= nil and Props.snapBackSpeed or .7
 
        Group.Border = display.newCircle(0,0,Props.borderSize)
        Group.Border.strokeWidth = 2
        --Group.Border:setFillColor  (Props.R,Props.G,Props.B,46)
        --Group.Border:setStrokeColor(Props.R,Props.G,Props.B,255)
        Group.Border:setFillColor  (Props.R,Props.G,Props.B,0)
        Group.Border:setStrokeColor(Props.R,Props.G,Props.B,0)
        Group:insert(Group.Border)
 
        Group.Thumb = display.newCircle(0,0,Props.thumbSize)
        Group.Thumb.strokeWidth = 3
        Group.Thumb:setFillColor  (Props.R,Props.G,Props.B,96)
        Group.Thumb:setStrokeColor(Props.R,Props.G,Props.B,255)
        Group.Thumb.x0 = 0
        Group.Thumb.y0 = 0
        Group:insert(Group.Thumb)
        Group.collisionDetected = false 
		Group.lockedAngle =  false
		Group.beingMoved = false
		
        ---------------------------------------------
        -- METHOD: DELETE STICK
        ---------------------------------------------
        function Group:delete()
                self.Border    = nil
                self.Thumb     = nil
                if self.Timer ~= nil then timer.cancel(self.Timer); self.Timer = nil end
                self:removeSelf()
        end
        
        ---------------------------------------------
        -- METHOD: MOVE AN OBJECT
        ---------------------------------------------
        function Group:move(Obj, maxSpeed, rotate)
                if rotate == true then Obj.rotation = self.angle end
                Obj.x = Obj.x + Cos( Rad(self.angle-90) ) * (maxSpeed * self.percent) 
                Obj.y = Obj.y + Sin( Rad(self.angle-90) ) * (maxSpeed * self.percent)
				
        end
		
		---------------------------------------------
        -- METHOD: SLIDE AN OBJECT
        ---------------------------------------------
        function Group:slide(Obj, maxSpeed)
			if (not Group.collisionDetected) then
				Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
				Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
				-- handle knockback on the player
				if (math.abs(Obj.knockbackX) > 2) then
					Obj.model.x = Obj.model.x + Obj.knockbackX
					Obj.knockbackX = Obj.knockbackX * .85
				end
				if (math.abs(Obj.knockbackY) > 2) then
					Obj.model.y = Obj.model.y + Obj.knockbackY
					Obj.knockbackY = Obj.knockbackY * .85
				end
			else 
				if(wallLoc == "r") then
					if(self.angle >= 180) then 
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					else
						Obj.model.x = Obj.markX
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
					end
				elseif(wallLoc == "l") then
					if(self.angle < 180) then 
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					else
						Obj.model.x = Obj.markX
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
					end
				elseif(wallLoc == "u") then 
					if(self.angle > 90 and self.angle < 270) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					else 
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = Obj.markY 
					end
				elseif(wallLoc == "d") then 
					if(self.angle <= 90 or self.angle >= 270) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					else 
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = Obj.markY 
					end
				elseif(wallLoc == "dl" or wallLoc == "ld") then 
					if(self.angle <= 90) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end			
				elseif(wallLoc == "dr" or wallLoc == "rd") then 
					if(self.angle >= 270) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end			
				elseif(wallLoc == "ru" or wallLoc == "ur") then 
					if(self.angle >= 180 and self.angle <= 270) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end	
				elseif(wallLoc == "ul" or wallLoc == "lu") then 
					if(self.angle > 90 and self.angle < 180) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end		
				elseif(wallLoc == "ud" or wallLoc == "du") then 
					Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
					Obj.model.y = Obj.markY
					Group.collisionDetected = false 
				elseif(wallLoc == "rl" or wallLoc == "lr") then 
					Obj.model.x = Obj.markX 
					Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
					Group.collisionDetected = false 
				elseif(wallLoc == "ulr") then 
					if(self.angle > 90 and self.angle < 270) then 
						Obj.model.x = Obj.markX 
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false
					end
				elseif(wallLoc == "lr") then 
					Obj.model.x = Obj.markX 
					Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
					Group.collisionDetected = false
				elseif(wallLoc == "uld") then 
					if(self.angle > 0 and self.angle < 180) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = Obj.markY
						Group.collisionDetected = false 
					end
				elseif(wallLoc == "urd") then 
					if(self.angle > 180) then 
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = Obj.markY
						Group.collisionDetected = false 
					end
				elseif(wallLoc == "lrd") then 
					if(self.angle < 90 or self.angle > 270) then 
						Obj.model.x = Obj.markX 
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false
					end
				elseif(wallLoc == "ulrd") then 
					Obj.model.x = Obj.markX 
					Obj.model.y = Obj.markY
				elseif(wallLoc == "TRD") then
					if(self.angle > 90) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end		
				elseif(wallLoc == "TLD") then
					if(self.angle < 270) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end	
				elseif(wallLoc == "BLD") then
					if(self.angle < 180 or self.angle > 270) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end	
				elseif(wallLoc == "BRD") then
					if(self.angle < 90 or self.angle > 180) then
						Obj.model.x = ( Obj.model.x + Cos( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Obj.model.y = ( Obj.model.y + Sin( Rad(self.angle-90) ) * (-maxSpeed * self.percent) )
						Group.collisionDetected = false 
					end	
				elseif(wallLoc == "noWall") then
					Group.collisionDetected = false 
				end
			end
        end
		
		function Group:collided(happened, x, y, loc)
			Group.collisionDetected = happened
			wallX = x
			wallY = y  
			wallLoc = loc
		end

		function Group:inCollision() 
			return Group.collisionDetected 
		end
		
		---------------------------------------------
		-- METHOD: ROTATE AN OBJECT
		---------------------------------------------
		function Group:rotate(Obj, rotate)
				if rotate == true then Obj.rotation = self.angle end
		end
        
        ---------------------------------------------
        -- GETTER METHODS
        ---------------------------------------------
        function Group:getDistance() return self.distance    end
        function Group:getPercent () return self.percent     end
        function Group:getAngle   () return Ceil(self.angle) end
		function Group:getMoving  () return Group.beingMoved end
		
        ---------------------------------------------
        -- HANDLER: ON DRAG
        ---------------------------------------------
        Group.onDrag = function ( event )
 
                local T     = event.target -- THUMB
                local S     = T.parent     -- STICK
                local phase = event.phase
                local ex,ey = S:contentToLocal(event.x, event.y)
                      ex = ex - T.x0
                      ey = ey - T.y0
 
                if "began" == phase then
						Group.beingMoved = true 
                        if S.Timer ~= nil then timer.cancel(S.Timer); S.Timer = nil end
                        --display.getCurrentStage():setFocus( T )
						display.getCurrentStage():setFocus( T, event.id )
                        T.isFocus = true
                        -- STORE INITIAL POSITION
                        T.x0 = ex - T.x
                        T.y0 = ey - T.y
 
                elseif T.isFocus then
                        if "moved" == phase then
                                -----------
                                S.distance    = Sqr (ex*ex + ey*ey)
                                if S.distance > S.maxDist then S.distance = S.maxDist end
                                S.angle       = ( (Atan2( ex-0,ey-0 )*180 / Pi) - 180 ) * -1
                                S.percent     = S.distance / S.maxDist
                                -----------
                                T.x       = Cos( Rad(S.angle-90) ) * (S.maxDist * S.percent) 
                                T.y       = Sin( Rad(S.angle-90) ) * (S.maxDist * S.percent) 
                        
                        elseif "ended"== phase or "cancelled" == phase then
								Group.beingMoved = false 
                                T.x0      = 0
                                T.y0      = 0
                                T.isFocus = false
                                --display.getCurrentStage():setFocus( nil )
								display.getCurrentStage():setFocus( nil, event.id )
                                S.Timer = timer.performWithDelay( 33, S.onRelease, 0 )
                                S.Timer.MyStick = S
                        end
                end
 
                -- STOP FURTHER PROPAGATION OF TOUCH EVENT!
                return true
 
        end
 
        ---------------------------------------------
        -- HANDLER: ON DRAG RELEASE
        ---------------------------------------------
        Group.onRelease = function( event )
 
                local S = event.source.MyStick
                local T = S.Thumb
 
                local dist = S.distance > S.maxDist and S.maxDist or S.distance
                          dist = dist * S.snapBackSpeed
 
                T.x = Cos( Rad(S.angle-90) ) * dist 
                T.y = Sin( Rad(S.angle-90) ) * dist 
 
                local ex = T.x
                local ey = T.y
                -----------
                S.distance = Sqr (ex*ex + ey*ey)
                if S.distance > S.maxDist then S.distance = S.maxDist end
                S.angle    = ( (Atan2( ex-0,ey-0 )*180 / Pi) - 180 ) * -1
                S.percent  = S.distance / S.maxDist
                -----------
                if S.distance < .5 then
                        S.distance = 0
                        S.percent  = 0
                        T.x            = 0
                        T.y            = 0
                        timer.cancel(S.Timer); S.Timer = nil
                end
 
        end
 
        Group.Thumb:addEventListener( "touch", Group.onDrag )
 
        return Group
 
end