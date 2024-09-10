hook.Add( "EntityFireBullets", "CustomEntityFireBullets", function( entity, data )
	-- hook into weapon firing to utilize new world pos and angles for player
	ply = entity
	if( !ply.WantRotate ) then return true end
	if( ply.Crouch == nil ) then ply.Crouch = 0 end

	_, CameraAngle = LocalToWorld( Vector(), ply:real_EyeAngles(), Vector(), ply:GetWAngles() )
	data.Dir = CameraAngle:Forward()
	data.Src = ply:GetPos()+ ply:GetWAngles():Forward()
	return true
end)

