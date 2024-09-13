function calcFootstep( ply, move, speed, GroundTrace )
	-- attempts to play a footstep sound based on input
	if(move:Length() > 0) then
		if( ply.LastFootstep == nil ) then ply.LastFootstep = 0 end
		if( ply.LeftFootstep == nil ) then ply.LeftFootstep = false end
		if( CurTime() > ply.LastFootstep ) then
			local sfc = util.GetSurfaceData(GroundTrace.SurfaceProps)
			ply.LeftFootstep = !ply.LeftFootstep
			ply.LastFootstep = CurTime()+0.35-0.5*(speed/0.00015-0.15)
			if( ply.LeftFootstep ) then
				EmitSound(sfc.stepLeftSound, ply:real_GetPos())
			else
				EmitSound(sfc.stepRightSound, ply:real_GetPos())
			end
		end
	end
end

hook.Add( "Move", "CustomMove", function( ply, mv )
	-- alters movement for player
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
	if( ply.vel == nil ) then ply.vel = Vector() end
	local ft = FrameTime()

	-- calculate speed
	local speed = 0.0015 * ft
	if( mv:KeyDown( IN_SPEED ) ) then speed = speed * 2 end

	-- find ground
	local PlyUp = ply:GetWAngles():Up()
	local GroundTrace = util.QuickTrace( ply:real_GetPos(), PlyUp*-32, ply )
	ply:SetGroundEntity(GroundTrace.Entity)

	-- calculate velocity to apply due to gravity
	local Grav = CalcGravVel(ply, nil)

	-- detect if 'grounded'
	ply.grounded = GroundTrace.Fraction < 1 and (ply.vel+Grav):Dot(PlyUp) < 0.3

	-- handle jump
	if( mv:KeyDown( IN_JUMP ) and ply.grounded ) then
		ply.vel = ply.vel + PlyUp*20
		speed = speed * 1.5
	end

	-- rotate speed to camera angle
	TempVec, CameraAngle = LocalToWorld( Vector(), Angle(0,ang.yaw,0), Vector(), ply:GetWAngles() )
	local move = Vector()
	move = move + CameraAngle:Forward() * mv:GetForwardSpeed() * speed
	move = move + CameraAngle:Right() * mv:GetSideSpeed() * speed
	move = move + CameraAngle:Up() * mv:GetUpSpeed() * speed

	if( ply.grounded ) then
		-- apply footstep sound
		calcFootstep(ply, move, speed, GroundTrace)
		-- apply ground friction
		ply.vel = ply.vel * math.pow(0.01,ft)
	end

	-- apply air friction
	if( ply:InAtmosphere() ) then
		ply.vel = ply.vel * math.pow(0.15,ft)
	end

	-- stop short of slamming us into ground with gravity
	local GravTrace = util.QuickTrace( ply:real_GetPos()+PlyUp, Grav+ply.vel, ply )
	Grav = Grav * math.max(0, GravTrace.Fraction-0.5) * ft

	-- adding gravity and movement
	ply.vel = ply.vel + Grav + move

	-- apply changes
	pos = pos + ply.vel
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
