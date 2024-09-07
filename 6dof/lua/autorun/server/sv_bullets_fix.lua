hook.Add( "EntityFireBullets", "CustomEntityFireBullets", function( entity, data )
	-- hook into weapon firing to utilize new world pos and angles for player
	ply = entity
	if( !ply.WantRotate ) then return true end
	if( ply.Crouch == nil ) then ply.Crouch = 0 end

	TempVec, CameraAngle = LocalToWorld( Vector(), ply:EyeAngles(), Vector(), ply:GetWAngles() )
	data.Dir = CameraAngle:Forward()
	data.Src = ply:GetPos() + Vector(0,0,15) - ply.newUpDir*15 + ply.newUpDir*ply.Crouch + ply:GetWAngles():Forward()
	return true
end)

