util.AddNetworkString( "WangleReciver" )
util.AddNetworkString( "WangleSender" )
util.AddNetworkString( "WRotateStatus" )

hook.Add( "Initialize", "6DofInit", function()
	RunConsoleCommand("sv_gravity", "0")
end)

hook.Add( "PlayerButtonDown", "6dofToggler", function( ply, button )
	-- send network event for crouch
	if( button == 19 ) then
		ply.WantRotate = !ply.WantRotate
		resetHull(ply)

		net.Start( "WRotateStatus" )
		    net.WriteBool( ply.WantRotate )
			net.Send( ply )
		end
end)