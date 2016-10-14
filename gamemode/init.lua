AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "specialchars.lua" )

include( 'shared.lua' )
include( 'specialchars.lua' )
 
//Called on each player spawn
function GM:PlayerSpawn(ply)
    self.BaseClass:PlayerSpawn(ply)
	ply:SetAllowWeaponsInVehicle( true )
	
	//Initial value so gmod can calm its tits
	ply.view = {origin = ply:GetPos(), angles = ply:EyeAngles(), posang = ply:EyeAngles(), fov = 72}
	
	//This entity is used to correct guns
	local pcam = ents.Create("pcam")
	pcam:SetOwner(ply)
	pcam:Spawn()
	ply:SetNWEntity("pcam", pcam) 

    ply:SetGravity( 0.00001 )  
    ply:SetWalkSpeed( 325 )  
	ply:SetRunSpeed( 325 )
	
	//Allows us to fix the viewmodel
	local oldhands = ply:GetHands();
	if ( IsValid( oldhands ) ) then
		oldhands:Remove()
	end
	//Needs a way of faking a new set of hands
end

//User Authentication parsing
local function userAuthed( ply, stid, unid )
	stid = ply:SteamID()
	CheckSpecialCharacters( ply, stid, unid )
	ply:SetTeam(1)
end
hook.Add( "PlayerAuthed", "playerauthed", userAuthed )

--no gravity on props
local function Init_TriggerLogic()
	physenv.SetGravity( Vector( 0, 0, 0 ) )
end
hook.Add( "InitPostEntity", "MapStartTrigger", Init_TriggerLogic )