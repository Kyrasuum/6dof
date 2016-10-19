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
//Create debug bounding box
//--------------------------------------------------------------------------
function GM:PreDrawViewModel(vm, weap)
	local ply = LocalPlayer()
	if(GetConVar( "planetview_debug" ):GetInt() == 1) then 
		local min, max = ply:WorldSpaceAABB()
			
		//Axis-Oriented Bounding box
		//Creating vectors for each point
		local aaa = min
		local aab = Vector(min.x, min.y, max.z)
		local abb = Vector(min.x, max.y, max.z)
		local aba = Vector(min.x, max.y, min.z)
		local bab = Vector(max.x, min.y, max.z)
		local baa = Vector(max.x, min.y, min.z)
		local bba = Vector(max.x, max.y, min.z)
		local bbb = max
		
		//12 lines make up a cube
		//min corner
		render.SetMaterial(Material( "cable/redlaser" ) )
		render.DrawBeam(aaa, aab,3,0,0, Color(255,255,255,255))
		render.DrawBeam(aaa, baa,3,0,0, Color(255,255,255,255))
		render.DrawBeam(aaa, aba,3,0,0, Color(255,255,255,255))
		//max corner
		render.DrawBeam(bbb, bba,3,0,0, Color(255,255,255,255))
		render.DrawBeam(bbb, bab,3,0,0, Color(255,255,255,255))
		render.DrawBeam(bbb, abb,3,0,0, Color(255,255,255,255))
		//remaining lines
		render.DrawBeam(aab, abb,3,0,0, Color(255,255,255,255))
		render.DrawBeam(aab, bab,3,0,0, Color(255,255,255,255))
		
		render.DrawBeam(baa, bab,3,0,0, Color(255,255,255,255))
		render.DrawBeam(baa, bba,3,0,0, Color(255,255,255,255))
		
		render.DrawBeam(aba, bba,3,0,0, Color(255,255,255,255))
		render.DrawBeam(aba, abb,3,0,0, Color(255,255,255,255))
	end
end

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

	local PlanetPos = GetPlanetPos(ply:RealGetPos())
	local NewAngles, NewOrigin, CorrecAng, PosAng = CalcRotation( ply, Origin, Angles )

	//Check if enabled
	if ( ply:GetMoveType() != MOVETYPE_NOCLIP ) then
		//Rotate Player model
		ply:SetAllowFullRotation(true)
		ply:RealSetAngles( CorrecAng )

		//Only change things if enabled and viewing from player
		if (ply:GetViewEntity() == ply)then
		
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
hook.Add( "ShouldCollide", "RammingDmg", RammingDmg )

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