hook.Add( "EntityFireBullets", "CustomEntityFireBullets", function( entity, data )
	-- hook into bullets being fired to utilize new world angles and positions of player
	ply = entity
	if( ply.Crouch == nil ) then ply.Crouch = 0 end
	if( ply.newUpDir == nil ) then ply.newUpDir = Vector() end
	ply.newUpDir = ply:GetWAngles():Up()

	TempVec, CameraAngle = LocalToWorld( Vector(), ply:EyeAngles(), Vector(), ply:GetWAngles() )
	data.Dir = CameraAngle:Forward()
	data.Src = ply.CameraFixPos

	return true
end)

