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

//Adjusts Viewmodel
function GM:PreDrawViewModel(vm, ply, weapon)
	//Old viewmodel
	if (ply != nil) then
		if(GetConVar("planetview_view_enable"):GetInt() == 1) then 
			//Edit viewmodel here
			
			//Calc Variables
			local PlanetPos = GetPlanetPos(ply:GetPos())
			local LocalPos = (ply:GetPos()-PlanetPos)
			local RollAng = Vector(-LocalPos.y,math.abs(LocalPos.z),0):AngleEx(Vector(0,0,0)).y -90
			local PitchAng = Vector(-LocalPos.x,LocalPos.z,0):AngleEx(Vector(0,0,0)).y -90
			local PosAng = Angle(PitchAng,0,-RollAng)
			local NewOrigin = ply:GetPos()+PosAng:Up()*61
			
			vm:SetPos( NewOrigin )
			vm:SetAngles( ply.view.angles )
		end
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
end

//Rotates plys 3d model
//Calculates the plys View (Does not rotate)
//Inputs the new ground object

local function CalcView(ply, Origin, Angles, FieldOfView)
	local View = {}
	View.origin = Origin
	View.angles = Angles
	View.fov = FieldOfView
	//Calc Variables
	local PlanetPos = GetPlanetPos(ply:GetPos())
	local LocalPos = (ply:GetPos()-PlanetPos)
	local RollAng = Vector(-LocalPos.y,math.abs(LocalPos.z),0):AngleEx(Vector(0,0,0)).y -90
	local PitchAng = Vector(-LocalPos.x,LocalPos.z,0):AngleEx(Vector(0,0,0)).y -90
	local PosAng = Angle(PitchAng,0,-RollAng)
	local EyeAng = ply:EyeAngles()
	local _,CorrecAng = LocalToWorld(Origin,Angle(0,EyeAng.y,0),Origin,PosAng)
		
	--ply View
	local NewOrigin = ply:GetPos()+CorrecAng:Up()*61
	local _,NewAng = LocalToWorld(Origin,Angle(EyeAng.p,0,0),Origin,CorrecAng)
		
	if (GetConVar("planetview_view_enable"):GetInt() == 1)then
		ply:SetAllowFullRotation(true)
		ply:SetAngles( CorrecAng )
		//Find our ground
		trace = util.TraceLine( {
			start = NewOrigin + PlanetPos,
			endpos = PlanetPos,
			mask = MASK_ALL,
			filter = ply
		} )

		if ( trace.Hit ) then
			ply:SetGroundEntity( world )			
		else
			//No Ground
		end
		--putting everything back in
		View.origin = NewOrigin
		View.angles = NewAng
		View.fov = FieldOfView
	end
	//Store it for outside access
	ply.view = View
	return View
end
hook.Add("CalcView", "CalcView", CalcView)