/*
Joining Dialog is created here
Collision handler is here
This File handles the calcview and viewmodel hooks
This is a good place to make edits to individual clients
*/
include( "shared.lua" )

//helmet hud
include( "VisorHud.lua" )

//--------------------------------------------------------------------------
//Joining Dialog
//--------------------------------------------------------------------------
function set_team() 
	local Ready = vgui.Create( "DFrame" )
	local width = 175
	local height = 75
	Ready:SetPos( (ScrW() - width) / 2, (ScrH() - height) / 2 )
	Ready:SetSize( width, height )
	Ready:SetTitle( "Welcome to the Server." )
	Ready:SetVisible( true )
	Ready:SetDraggable( false )
	Ready:ShowCloseButton( false )
	Ready:MakePopup()
	ready1 = vgui.Create( "DButton", Ready )
	ready1:SetPos( 20, 25 )
	ready1:SetSize( 140, 40 )
	ready1:SetText( "Ok" )
	ready1.DoClick = function()
		//unspectate
		Ready:Hide()
		RunConsoleCommand( "unspectate" )
	end
end
concommand.Add( "sb_start", set_team )

//--------------------------------------------------------------------------
//Adjusts Viewmodel
//--------------------------------------------------------------------------
function GM:CalcViewModelView( wep, vm, oldPos, oldAng, pos, ang )
	if ( !IsValid( wep ) ) then return end
	local ply = LocalPlayer()
	local vm_origin, vm_angles = pos, ang
	
	// Planetview adjustment
	if (ply != nil) then
		//Only change things if enabled and viewing from player
		if( ply:GetMoveType() != MOVETYPE_NOCLIP && ply:GetViewEntity() == ply ) then 
			//Edit viewmodel here
			vm_angles, vm_origin = CalcRotation( ply, vm_origin, vm_angles )
		end
	end

	-- Controls the position of all viewmodels
	local func = wep.GetViewModelPosition
	if ( func ) then
		local Rpos, Rang = func( wep, vm_origin*1, vm_angles*1 )
		vm_origin = Rpos or vm_origin
		vm_angles = Rang or vm_angles
	end

	-- Controls the position of individual viewmodels
	func = wep.CalcViewModelView
	if ( func ) then
		local Rpos, Rang = func( wep, vm, vm_origin*1, vm_angles*1, vm_origin*1, vm_angles*1 )
		vm_origin = Rpos or vm_origin
		vm_angles = Rang or vm_angles
	end
	return vm_origin, vm_angles
end
//--------------------------------------------------------------------------
//Rotates players 3d model and view
//Inputs the new ground object (not effective yet)
//--------------------------------------------------------------------------
function GM:CalcView(ply, Origin, Angles, FieldOfView)
	local View = {}

	//Check if enabled
	if ( ply:GetMoveType() != MOVETYPE_NOCLIP ) then
		local NewAngles, NewOrigin, CorrecAng, PosAng = CalcRotation( ply, Origin, Angles )
		//Rotate Player model
		ply:SetAllowFullRotation(true)
		ply:RealSetAngles( CorrecAng )

		//Only change things if enabled and viewing from player
		if (ply:GetViewEntity() == ply)then
			local PlanetPos = GetPlanetPos(ply:RealGetPos())

			Origin = NewOrigin
			Angles = NewAngles
			
			//Find our ground
			trace = util.TraceLine( {
				start = Origin + PlanetPos,
				endpos = PlanetPos,
				mask = MASK_ALL,
				filter = ply
			} )

			if ( trace.Hit ) then
				ply:SetGroundEntity( world )			
			else
				//No Ground
			end
		end

		//Syncing server
		net.Start( "View" )
			net.WriteVector( NewOrigin )
			net.WriteAngle( NewAngles )
		net.SendToServer()
	else
		//Syncing server
		net.Start( "View" )
			net.WriteVector( Origin )
			net.WriteAngle( Angles )
		net.SendToServer()		
	end

	--putting everything back in
	View.origin = Origin
	View.angles = Angles
	View.fov = FieldOfView
	return View
end

//Recieving sound data from server
net.Receive( "Sound", function( len )
	local tbl = net.ReadTable()
	local data = net.ReadTable()
	local ply = LocalPlayer()
	InAtmosphere( ply )

	for _, ent in pairs( tbl ) do
		if ( ent == ply:GetGroundEntity() ) then
			//dampen by distance
			data.Volume = data.Volume - math.abs( 20 * math.log10( 1 
						/ ( data.Entity:GetPos() - ply:GetPos() ):Length() ) )
			break//quick exit
		end
	end
	sound.Play( data.SoundName, data.Entity:GetPos(), data.SoundLevel, data.Pitch, data.Volume )
end )


//Space crashing damage
function RammingDmg( ent1, ent2 )
	//Relative velocity
	local relVel = (ent1:GetVelocity() - ent2:GetVelocity()):Length()
	
	//Take dmg
	ent1:TakeDamage( ent2:GetPhysicsObject():GetMass() * relVel / ent1:GetPhysicsObject():GetMass(), ent2, ent2 )
	ent2:TakeDamage( ent1:GetPhysicsObject():GetMass() * relVel / ent2:GetPhysicsObject():GetMass(), ent1, ent1 )
	
	//Assign ground if player
	if (ent1:IsGround()) then
		ent2:SetGroundEntity(ent1)
		ent2:AddFlag(FL_ONGROUND)
	end
	if (ent2:IsGround()) then
		ent1:SetGroundEntity(ent2)
		ent1:AddFlag(FL_ONGROUND)
	end
end
//hook.Add( "ShouldCollide", "RammingDmg", RammingDmg )

//Space chat rules
function GM:OnPlayerChat( src, txt, bool, booldead )
	local tab = {}
	//from dead dude
	if ( booldead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end
	//team chat
	if ( bool ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "( TEAM ) " )
	end

	if ( IsValid( src ) ) then
		//Add players name
		table.insert( tab, src )
		//global chat
		if ( string.sub( txt, 1, 4 ) == "/all" ) then
			if (src:IsOwner()) then table.insert( tab, "[Owner]" )
			elseif (src:IsSuperAdmin()) then table.insert( tab, "[SuperAdmin]" )
			elseif (src:IsAdmin()) then table.insert( tab, "[Admin]" )
			else table.insert( tab, "[Global]" ) end
			txt = string.sub( txt, 5 ) 
		end
	else
		//from console
		table.insert( tab, "Console" )
	end
	
	//Add their text
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..txt )
	

	chat.AddText( unpack( tab ) )
	//Block normal chat
	return true
end

//3d name above player's head
function DrawName( ply )
	if ( !IsValid( ply ) ) then return end
	if ( ply == LocalPlayer() ) then return end -- Don't draw a name when the player is you
	if ( !ply:Alive() ) then return end -- Check if the player is alive

	local Distance = LocalPlayer():GetPos():Distance( ply:GetPos() ) --Get the distance between you and the player

	if ( Distance < 1000 ) then --If the distance is less than 1000 units, it will draw the name

		local offset = Vector( 0, 0, 85 )
		local ang = LocalPlayer():EyeAngles()
		local pos = ply:GetPos() + offset + ang:Up()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )


		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
			draw.DrawText( ply:GetName(), "HudSelectionText", 2, 2, team.GetColor( ply:Team() ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end
hook.Add( "PostPlayerDraw", "DrawName", DrawName )




//--------------------------------------------------------------------------
//Movement Override as a drive module
//--------------------------------------------------------------------------

-- Derive from drive_base ( see lua/drive/drive_base.lua
DEFINE_BASECLASS( "drive_base" );

drive.Register( "drive_example",
{
	--
	-- Calculates the view when driving the entity
	--
	CalcView = function( self, view )

		--
		-- Use the utility method on drive_base.lua to give us a 3rd person view
		--
		self:CalcView_ThirdPerson( view, 100, 2, { self.Entity } )
		view.angles.roll = 0

	end,

	--
	-- Called before each move. You should use your entity and cmd to
	-- fill mv with information you need for your move.
	--
	StartMove = function( self, mv, cmd )
		-- Set observer mode to chase, so the entity will be drawn.
		self.Player:SetObserverMode( OBS_MODE_CHASE )
		--
		-- Update move position and velocity from our entity
		--
		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )

	end,

	--
	-- Runs the actual move. On the client when there's
	-- prediction errors this can be run multiple times.
	-- You should try to only change mv.
	--
	Move = function( self, mv )

		--
		-- Set up a speed, go faster if shift is held down
		--
		local speed = 0.0005 * FrameTime()
		if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.005 * FrameTime() end

		--
		-- Get information from the movedata
		--
		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()

		--
		-- Add velocities. This can seem complicated. On the first line
		-- we're basically saying get the forward vector, then multiply it
		-- by our forward speed ( which will be > 0 if we're holding W, < 0 if we're
		-- holding S and 0 if we're holding neither ) - and add that to velocity.
		-- We do that for right and up too, which gives us our free movement.
		--
		vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
		vel = vel + ang:Right() * mv:GetSideSpeed() * speed
		vel = vel + ang:Up() * mv:GetUpSpeed() * speed

		--
		-- We don't want our velocity to get out of hand so we apply
		-- a little bit of air resistance. If no keys are down we apply
		-- more resistance so we slow down more.
		--
 		if ( math.abs( mv:GetForwardSpeed() ) + math.abs( mv:GetSideSpeed() ) + math.abs( mv:GetUpSpeed() ) < 0.1 ) then
			vel = vel * 0.90
		else
			vel = vel * 0.99
		end

		--
		-- Add the velocity to the position ( this is the movement )
		--
		pos = pos + vel

		--
		-- We don't set the newly calculated values on the entity itself
		-- we instead store them in the movedata. These get applied in F inishMove.
		--
		mv:SetVelocity( vel )
		mv:SetOrigin( pos )

	end,

	--
	-- The move is finished. Use mv to set the new positions
	-- on your entities/players.
	--
	FinishMove = function( self, mv )

		--
		-- Update our entity!
		--
		self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		self.Entity:SetAbsVelocity( mv:GetVelocity() )
		self.Entity:SetAngles( mv:GetMoveAngles() )

		--
		-- If we have a physics object update that too. But only on the server.
		--
		if ( SERVER && IsValid( self.Entity:GetPhysicsObject() ) ) then

			self.Entity:GetPhysicsObject():EnableMotion( true )
			self.Entity:GetPhysicsObject():SetPos( mv:GetOrigin() );
			self.Entity:GetPhysicsObject():Wake()
			self.Entity:GetPhysicsObject():EnableMotion( false )

		end

	end,

}, "drive_base" );