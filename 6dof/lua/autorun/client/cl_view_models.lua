local function defaultCam( wep, vm, oldPos, oldAng, pos, ang )
	ang = CameraAngle
	pos = ply.CameraFixPos

	return pos, ang
end

local function calculateMoves( ply )
	-- rotate players move directions to players world angles
	if( ply.viewVelocity == nil ) then ply.viewVelocity = Vector() end
	if( ply.viewLerpVelocity == nil ) then ply.viewLerpVelocity = Vector() end

	ply.viewVelocity = Vector()

	if ( ply:KeyDown( IN_FORWARD ) ) then
		ply.viewVelocity = ply.viewVelocity + Vector(1,0,0)
	end
	if ( ply:KeyDown( IN_BACK ) ) then
		ply.viewVelocity = ply.viewVelocity + Vector(-1,0,0)
	end
	if ( ply:KeyDown( IN_MOVELEFT ) ) then
		ply.viewVelocity = ply.viewVelocity + Vector(0,-1,0)
	end
	if ( ply:KeyDown( IN_MOVERIGHT ) ) then
		ply.viewVelocity = ply.viewVelocity + Vector(0,1,0)
	end
	if ( ply:KeyDown( IN_SPEED ) ) then
		ply.viewVelocity = ply.viewVelocity * 2
	end
	if ( ply:KeyDown( IN_WALK ) ) then
		ply.viewVelocity = ply.viewVelocity / 2
	end

	ply.viewLerpVelocity = LerpVector(5*FrameTime(),ply.viewLerpVelocity,ply.viewVelocity)
end


hook.Add( "CalcViewModelView", "HumansViewModel", function( wep, vm, oldPos, oldAng, pos, ang )
	-- update view model for player
	ply = LocalPlayer()
	if ( !ply.WantRotate ) then
		return true
	end
	if( ply.StepsX == nil ) then ply.StepsX = 0 end
	if( ply.StepsMultiply == nil ) then ply.StepsMultiply = 0 end
	if( ply.LerpWAngles == nil ) then ply.LerpWAngles = Angle() end
	if( ply.PrevAngle == nil ) then ply.PrevAngle = Angle() end
	if( finalPos == nil ) then finalPos = Vector() end

	if( finalPos:Distance(ply.oldCamPos) > 150 ) then
		return false
	end

	return defaultCam(wep, vm, oldPos, oldAng, pos, ang)
end )

