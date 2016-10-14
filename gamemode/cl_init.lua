/*
This File handles the calcview and viewmodel hooks
This is a good place to make edits to individual clients
*/
include( "shared.lua" )

//Adjusts Viewmodel
//Corrects Bounding Box
//Creates Debug box
function GM:PreDrawViewModel(vm, Player, weapon)
	//Old viewmodel
	if(Player != nil && Player != NULL && GetConVar("planetview_view_enable"):GetInt() == 1) then 
		//Edit viewmodel here
		vm:SetAngles( Player.view.angles )
		vm:SetPos( Player.view.origin )
	end
end

//Rotates Players 3d model
//Calculates the Players View (Does not rotate)
//Inputs the new ground object
local function CalcView(Player, Origin, Angles, FieldOfView)
	local View = {}
	View.origin = Origin
	View.angles = Angles
	View.posang = Angles
	View.fov = FieldOfView
	if (GetConVar("planetview_view_enable"):GetInt() == 2 && Player:GetMoveType() != MOVETYPE_NOCLIP)then
		Player:SetAllowFullRotation(true)
		
		//Calc Variables
		local PlanetPos = GetPlanetPos(Player:GetPos())
		local LocalPos = (Player:GetPos()-PlanetPos)
		local RollAng = Vector(-LocalPos.y,math.abs(LocalPos.z),0):AngleEx(Vector(0,0,0)).y -90
		local PitchAng = Vector(-LocalPos.x,LocalPos.z,0):AngleEx(Vector(0,0,0)).y -90
		local PosAng = Angle(PitchAng,0,-RollAng)
		local EyeAng = Player:EyeAngles()
		local _,CorrecAng = LocalToWorld(Origin,Angle(0,EyeAng.y,0),Origin,PosAng)
		
		Player:SetAngles( CorrecAng )
		
		--Player View
		local NewOrigin = Player:GetPos()+CorrecAng:Up()*61
		local _,NewAng = LocalToWorld(Origin,Angle(EyeAng.p,0,0),Origin,CorrecAng)
		
		//Find our ground
		trace = util.TraceLine( {
			start = NewOrigin + PlanetPos,
			endpos = PlanetPos,
			mask = MASK_ALL,
			filter = Player
		} )

		if ( trace.Hit ) then
			Player:SetGroundEntity( world )			
		else
			//No Ground
		end
		--putting everything back in
		View.origin = NewOrigin
		View.angles = NewAng
		View.posang = PosAng
		View.fov = FieldOfView
	end
	//Store it for outside access
	Player.view = View
	//View is rotated elsewhere
	View.origin = Origin
	View.angles = Angles
	View.posang = Angles
	View.fov = FieldOfView
	return View
end
hook.Add("CalcView", "CalcView", CalcView)