local function defaultCam( wep, vm, oldPos, oldAng, pos, ang )
	ang = CameraAngle
	pos = ply.CameraFixPos

	return pos, ang
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

