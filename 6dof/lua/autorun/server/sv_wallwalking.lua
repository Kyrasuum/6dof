util.AddNetworkString( "WangleReciver" )
util.AddNetworkString( "WangleSender" )
util.AddNetworkString( "WRotateStatus" )

function calcAngles( ply )
	-- get input variables for calculating players world angle
	local Planet,_ = FindNearestEntity( "planetphys", ply, 65535 )
	local PlanetPos = Vector()
	local LocalPos = ply:real_GetPos()
    local ViewAngles = ply:real_EyeAngles()
	local NewAngle = Angle()

	-- Calculate players rotation
	if( Planet ~= nil ) then
		PlanetPos = Planet:GetPos()
	end 
	local PlanetNormal = (LocalPos - PlanetPos):GetNormalized()

	local PlyUp = Angle(0, ViewAngles.y, 0):Up()
	local Axis = PlyUp:Cross(PlanetNormal):GetNormalized()
	local Dot = PlyUp:Dot(PlanetNormal)
	local Ang = math.deg(math.acos(math.Clamp(Dot, -1, 1)))
	local Quat = Quaternion()
	Quat:SetAngleAxis(Ang, Axis)

	NewAngle = Quat:Angle()

	-- rollover for angles
	NewAngle:Normalize()

	-- broadcast new player angles
	ply:SetWAngles( NewAngle )
	net.Start( "WangleSender" )
		net.WriteEntity( ply )
	    net.WriteAngle( NewAngle )
	net.Broadcast()
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


hook.Add( "Move", "CustomMove", function( ply, mv )
	if( !ply.WantRotate ) then
		return mv
	end

	-- check for crouch
	if( ply.Crouch == nil ) then ply.Crouch = 0 end
	ply.Crouch = 65
	if( ply:KeyDown(IN_DUCK) ) then
		ply.Crouch = 40
	end

	local ang = mv:GetMoveAngles()
	local pos = mv:GetOrigin()
	local vel = mv:GetVelocity()

	-- calculate speed
	local speed = 0.0025 * FrameTime()
	if ( mv:KeyDown( IN_SPEED ) ) then speed = speed * 2 end

	-- find ground
	if( ply.newUpDir == nil ) then ply.newUpDir = Vector() end
	ply.newUpDir = ply:GetWAngles():Up()
	GroundTrace = util.QuickTrace( ply:GetPos() + ply.newUpDir*32 , ply.newUpDir*-60 , ply )
	DistToGround = GroundTrace.HitPos:Distance( GroundTrace.StartPos )
	
	-- adding gravity
	if( ply.vel == nil ) then ply.vel = Vector() end

	local _,PlanetDist = FindNearestEntity( "planetphys", ply, 65535 )
	ply.vel = ply.vel - ( ply.newUpDir*(1 - PlanetDist/65535)*(50)*(DistToGround/38 - 1) )*FrameTime()

	-- rotate speed to camera angle
	TempVec, CameraAngle = LocalToWorld( Vector(), Angle(0,ang.yaw,0), Vector(), ply:GetWAngles() )
	ply.vel = ply.vel + CameraAngle:Forward() * mv:GetForwardSpeed() * speed
	ply.vel = ply.vel + CameraAngle:Right() * mv:GetSideSpeed() * speed
	ply.vel = ply.vel + CameraAngle:Up() * mv:GetUpSpeed() * speed
	ply.vel = ply.vel * 60 * FrameTime()
	pos = pos + ply.vel

	-- handle jump
	if ( mv:KeyDown( IN_JUMP ) and DistToGround-50 < 5 ) then 
		ply.vel = ply.vel + ply.newUpDir * 5
		ply:SetVelocity( ply.vel*10 )
	end

	-- apply changes
	mv:SetVelocity( ply.vel )
	mv:SetOrigin( pos )

	return true
end)

hook.Add( "FinishMove", "CustomFinishMove", function( ply, mv )
	-- only send networked origin when rotating
	if ( !ply.WantRotate ) then
		return false
	end
	ply:SetNetworkOrigin( mv:GetOrigin() )
	return true
end)


hook.Add( "PlayerButtonDown", "CrawlToggler", function( ply, button )
	-- send network event for crouch
	if( button == 19 ) then
		ply.WantRotate = ~ply.WantRotate
		resetHull(ply)

		net.Start( "WRotateStatus" )
		    net.WriteBool( ply.WantRotate )
		net.Send( ply )
	end
end)
