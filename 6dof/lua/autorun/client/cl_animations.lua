-- reciever for world angles on player
net.Receive( "WangleSender", function( len )
	ply = net.ReadEntity()
    ply.WAngles = net.ReadAngle()
end )

function rotatePlayer( ply )
	-- rotates the players bones (model) to the new world angle
	WAngle = ply:GetWAngles() 
	if( ply.WAngleLerp == nil ) then ply.WAngleLerp = Angle() end
	if( ply.PrevPose == nil ) then ply.PrevPose = Vector() end
	if( ply.NewAngle == nil ) then ply.NewAngle = Angle() end

	ply.WAngleLerp = LerpAngle(  0.15*FrameTime()*30 , ply.WAngleLerp, WAngle )

	TempVec, NewAngle = LocalToWorld( Vector(), Angle(0,ply:EyeAngles().yaw,0), Vector(), ply.WAngleLerp )
	LocalVelocity, TrashVar = WorldToLocal( ( ply:GetPos() - ply.PrevPose ), Angle() , Vector(), NewAngle )

	ply.NewAngle = NewAngle

	ply:SetRenderAngles( NewAngle )
	ply:ManipulateBonePosition(0, Vector(0,0,-15*(1-math.abs(WAngle:Up().z)*( Lerp(0.5,0,WAngle:Up().z+1) ) ) ) )

	ply:SetPoseParameter("move_y", -LocalVelocity.y/2 )
	ply:SetPoseParameter("move_x", LocalVelocity.x )

	ply.PrevPose = LerpVector(1*FrameTime()*30,ply.PrevPose,ply:GetPos() )
end

hook.Add( "PreDrawOpaqueRenderables" , "rotatePlayers" , function( isDrawingDepth, isDrawSkybox, isDraw3DSkybox )
	-- hook into draw call to rotate player first
	for i, ply in ipairs( player.GetAll() ) do
		rotatePlayer( ply )
	end
end )

hook.Add("UpdateAnimation" , "CustomUpdateAnimation" , function( ply, velocity, maxSeqGroundSpeed )
	-- fixing animations
	-- note: test to see what effect this has
	if( ply.NewAngle == nil ) then return false end
	
	if( !ply.WantRotate ) then
		ply.PrevSequence = ply:GetSequence()
	else
		ply:SetSequence( ply.PrevSequence )
		return true
	end
end)
