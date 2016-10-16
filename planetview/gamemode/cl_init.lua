/*
Joining Dialog is created here
This File handles the calcview and viewmodel hooks
This is a good place to make edits to individual clients
*/
include( "shared.lua" )

//Joining Dialog
function set_team() 
	Ready = vgui.Create( "DFrame" )
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

//Create debug bounding box
function GM:PreDrawViewModel(vm, weap)
	local ply = LocalPlayer()
	if(GetConVar("planetview_debug"):GetInt() == 1) then 
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

//Adjusts Viewmodel
function GM:CalcViewModelView( wep, vm, oldPos, oldAng, pos, ang )
	ply = LocalPlayer()
	if (ply != nil) then
		if(GetConVar("planetview_view_enable"):GetInt() == 1) then 
			//Edit viewmodel here	
			pos = ply:GetNWVector("origin") 
			ang = ply:GetNWAngle("angles")
		end
	end
	return pos, ang
end
//Rotates plys 3d model
//Calculates the plys View (Does not rotate)
//Inputs the new ground object
function GM:CalcView(ply, Origin, Angles, FieldOfView)
	local View = {}
	//Only change things if enabled
	if (GetConVar("planetview_view_enable"):GetInt() == 1)then
		//Calc Variables
		local PlanetPos = GetPlanetPos(ply:RealGetPos())
		local LocalPos = (ply:RealGetPos()-PlanetPos)
		local LocalPos = (ply:RealGetPos()-PlanetPos)
		local RollAng = Vector(-LocalPos.y,math.abs(LocalPos.z),0):AngleEx(Vector(0,0,0)).y -90
		local PitchAng = Vector(-LocalPos.x,LocalPos.z,0):AngleEx(Vector(0,0,0)).y -90
		local PosAng = Angle(PitchAng,0,-RollAng)
		local EyeAng = ply:RealEyeAngles()
		local _,CorrecAng = LocalToWorld(Origin,Angle(0,EyeAng.y,0),Origin,PosAng)
			
		--ply View
		local _,NewAng = LocalToWorld(Origin,Angle(EyeAng.p,0,0),Origin,CorrecAng)
		local Origin = ply:RealGetPos()+CorrecAng:Up()*61
		
		ply:SetAllowFullRotation(true)
		ply:SetAngles( CorrecAng )
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
	--putting everything back in
	View.origin = Origin
	View.angles = Angles
	View.fov = FieldOfView
	//Quicker than server update (visual only)
	ply:SetNWVector("origin", Origin)
	ply:SetNWAngle("angles", Angles)
	//Syncing server
	net.Start( "View" )
		net.WriteVector( Origin )
		net.WriteAngle( Angles )
	net.SendToServer()
	return View
end