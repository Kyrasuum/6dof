-- reciever for world rotation status
net.Receive( "WRotateStatus", function( len )
    ply.WantRotate = net.ReadBool()
end )

local function defaultCam( ply, pos, angles, fov )
	-- rotate camera to new world angles for player
	ply.Crouch = 1
	local angleToLerp = ply:GetWAngles()
	if( !ply.WantRotate ) then
		angleToLerp = Angle(0,angleToLerp.yaw,0)
		ply.Crouch = 0
	end

	-- calculate amount to lerp as camera changes
	ply.CrouchLerp = Lerp( 40*FrameTime(), ply.CrouchLerp , ply.Crouch )
	ply.LerpWAngles = LerpAngle(  0.2*FrameTime()*50 , ply.LerpWAngles,angleToLerp )
	TempVec, CameraAngle = LocalToWorld( Vector(), angles, Vector(), ply.LerpWAngles )
	finalPos = ply:GetPos() + Vector(0,0,15) - ply.LerpWAngles:Up()*15 + ply.LerpWAngles:Up()*63
	ply.CameraFixPos = LerpVector( ply.CrouchLerp , pos, finalPos )

	-- snap when difference is too large
	if( finalPos:Distance(pos) > 150 ) then
		return view
	end
	-- lerp otherwise
	return {
		origin = ply.CameraFixPos,
		angles = CameraAngle,
		fov = fov,
		drawviewer = false
	}
end


hook.Add( "CalcView", "HumansCamera", function( ply, pos, angles, fov )
	if ( !ply.WantRotate ) then
		return true
	end
	-- update camera for player
	if( ply.StepsX == nil ) then ply.StepsX = 0 end
	if( ply.StepsMultiply == nil ) then ply.StepsMultiply = 0 end
	if( ply.LerpWAngles == nil ) then ply.LerpWAngles = Angle() end
	if( ply.PrevAngle == nil ) then ply.PrevAngle = Angle() end
	if( ply.Crouch == nil ) then ply.Crouch = 0 end
	if( ply.CrouchLerp == nil ) then ply.CrouchLerp = 0 end
	if( ply.CameraFixPos == nil ) then ply.CameraFixPos = Vector() end

	ply.oldCamPos = pos
	return defaultCam(ply, pos, angles, fov)
end )
