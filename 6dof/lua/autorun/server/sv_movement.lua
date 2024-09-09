function calcGravity( ply, DistToGround )
	-- calculate velocity to apply due to gravity
	local _,PlanetDist = FindNearestGravBody( ply, 65535 )
	return -( ply.newUpDir*(1 - PlanetDist/65535)*(50)*(DistToGround/38 - 1) )*FrameTime()
end

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
	GroundTrace = util.QuickTrace( ply:GetPos() + ply.newUpDir*32 , ply.newUpDir*-100 , ply )
	DistToGround = GroundTrace.HitPos:Distance( GroundTrace.StartPos )
	
	-- adding gravity
	if( ply.vel == nil ) then ply.vel = Vector() end
	ply.vel = ply.vel + calcGravity( ply, DistToGround )
	

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
