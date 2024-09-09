function calcAngles( ply )
	-- get input variables for calculating players world angle
	local Planet,_ = FindNearestGravBody( ply, 65535 )
	local Center = Vector()
	local LocalPos = ply:real_GetPos()
	local PlyRot = ply:GetWAngles()
    local ViewAngles = ply:real_EyeAngles()
	local NewAngle = Angle()

	-- find normal position from nearest planet core offset
	if( Planet ~= nil ) then
		Center = Planet:GetPos()
	end 
	local Normal = (LocalPos - Center):GetNormalized()

	-- find quaternion rotation
	local PlyUp = PlyRot:Up()
	local PlyFwd = PlyRot:Forward()
	if( PlyUp:Distance( Normal ) > 0.01 ) then
		-- calculate a forward vector parallel to surface
		local Right = PlyFwd:Cross(Normal)
		local Forward = Normal:Cross(Right)
		
		-- create quaternion from normal and forward
		local Quat = Quaternion()
		Quat:SetDirection(Forward, Normal)

		-- calculate rotation from quaternion
		NewAngle = Quat:Angle()

		-- rollover for angles
		NewAngle:Normalize()

		-- broadcast new player angles
		ply:SetWAngles( NewAngle )
	end
end

function stickToProp( ply )
	-- find prop to stick to
	PrevAngle = ply:GetWAngles()
	PropCheck = util.QuickTrace( ply:GetPos() + Vector(0,0,15) - PrevAngle:Up()*15 + PrevAngle:Up()*65, PrevAngle:Up()*-400 , ply )
	if( ply.PropPos == nil ) then ply.PropPos = Vector() end
	if( ply.PropAngles == nil ) then ply.PropAngles = Angle() end
	if( ply.LocalProp == nil ) then ply.LocalProp = Entity(0) end
	local hitEnt = PropCheck.Entity
	if( PropCheck.HitWorld ) then
		ply.PropAngles = Angle()
		ply.PropPos = Vector()
	end

	if( IsValid(hitEnt) && ply.LocalProp == hitEnt ) then
		-- add prop's linear and angular velocities to player to 'glue' player to prop
		local propVel = hitEnt:GetPos() - ply.PropPos
		local propVelAngle = ( hitEnt:GetAngles() - ply.PropAngles )
		if( ply.PropPos:Distance( Vector() ) > 100 && ply.PropAngles ~= Angle() ) then
			ply:SetPos( ply:GetPos() + propVel )
			ply:SetWAngles( PrevAngle - propVelAngle )
		end
		ply.PropAngles = hitEnt:GetAngles()
		ply.PropPos = hitEnt:GetPos()
	else
		ply.PropAngles = Angle()
		ply.PropPos = Vector()
		ply.LocalProp = hitEnt
	end
end

function updateHull( ply )
	-- performs an update to player hull to fix collisions
	if( !ply.WantRotate ) then return end
	NewAngle = ply:GetWAngles()
	PrevHullAngle = Angle()
	NewHullAngle = Angle()

	-- calculate hulls
	newBottom = Vector(-16, -16, 0)
	newTop = Vector(16, 16, 72)
	newBottom:Rotate(NewAngle)
	newTop:Rotate(NewAngle)

	newBottomDuck = Vector(-16, -16, 0)
	newTopDuck = Vector(16, 16, 72)
	newBottomDuck:Rotate(NewAngle)
	newTopDuck:Rotate(NewAngle)
	
	local prevBottom, prevTop = ply:GetHull()

	-- calculate if should update hull
	local prevHullNormal = (prevTop - prevBottom):GetNormalized()
	PrevHullAngle.yaw = math.deg(math.atan2(prevHullNormal.y, prevHullNormal.x))
	PrevHullAngle.pitch = math.deg(math.acos(prevHullNormal.z))
	local newHullNormal = (newTop - newBottom):GetNormalized()
	NewHullAngle.yaw = math.deg(math.atan2(newHullNormal.y, newHullNormal.x))
	NewHullAngle.pitch = math.deg(math.acos(newHullNormal.z))

	-- prefer to update when needed
	if(NewHullAngle:Up():Distance(PrevHullAngle:Up()) > 0.1) then
		-- update player hull for collisions
		ply:SetHull( newBottom, newTop )
		ply:SetHullDuck( newBottomDuck, newTopDuck )
	end
end

function resetHull( ply )
	-- resets hull to sane defaults
	if( ply.hullBottom == nil ) then ply.hullBottom, ply.hullTop = ply:GetHull() end
	if( ply.hullBottomDuck == nil ) then ply.hullBottomDuck, ply.hullTopDuck = ply:GetHullDuck() end
	ply:ResetHull()
	
	if( ply.WantRotate ) then
		newBottom = ply.hullBottom
		newTop = ply.hullTopDuck

		newBottom = newBottom
		newTop = newTop + Vector(0,0,-18)

		newTop = newTop/2 
		newBottom = newBottom/2

		ply:SetHull( newBottom, newTop )
	else
		-- reset angle here as well to allow reseting player to upright
		NewAngle = Angle()
		ply:SetWAngles( NewAngle )
		net.Start( "WangleSender" )
			net.WriteEntity( ply )
			net.WriteAngle( NewAngle )
		net.Broadcast()
	end
end

hook.Add( "Tick", "ServerLoop", function()
	-- process all players to apply 6dof
	for i, v in ipairs( player.GetAll() ) do
    	calcAngles( v )
    	stickToProp( v )

		-- more accurate hull but is unstable
		-- updateHull( v )
	end
end )
