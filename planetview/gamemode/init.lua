/*
This File handles the player spawning and authentication
Good hooks for server side edits
*/
AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "specialchars.lua" )

include( 'shared.lua' )
include( 'specialchars.lua' )
 
//User Authentication parsing
function GM:PlayerAuthed( ply, stid, unid )
	RunConsoleCommand( "sb_start" )
	stid = ply:SteamID()
	ply:SetTeam(1)
	ply:Spectate( 5 )
	CheckSpecialCharacters( ply, stid, unid )
end
//Restrict some weapons
function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	if (ply:Team() >= 2) then //Guest
        ply:Give( "weapon_physcannon" )
		ply:Give( "weapon_physgun" )
		ply:Give( "gmod_tool" )
    end
	if (ply:Team() >= 3) then //Member
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_smg1" )
		ply:Give( "weapon_crowbar" )
	 
		ply:GiveAmmo( 999, "pistol" )
		ply:GiveAmmo( 999, "smg1" )
    end
	if (ply:Team() >= 4) then //Admin+
		ply:Give( "weapon_frag" )
		ply:Give( "weapon_crossbow" )
		ply:Give( "weapon_shotgun" )
		ply:Give( "weapon_357" )
		ply:Give( "weapon_rpg" )
		ply:Give( "weapon_ar2" )
	    ply:Give( "gmod_camera" )
    end
end

//Used on initial spawn
function unspectate( ply ) 
	ply:UnSpectate()
	ply:Spawn()
end
concommand.Add( "unspectate", unspectate )
 
//Called on each player spawn
function GM:PlayerSpawn(ply)
    self.BaseClass:PlayerSpawn(ply)
	ply:SetAllowWeaponsInVehicle( true )
	
	//Initial value so gmod can calm its tits
	ply.view = {origin = ply:GetPos(), angles = ply:EyeAngles(), posang = ply:EyeAngles(), fov = 72}
	
	//This entity is used to correct guns
	//local pcam = ents.Create("pcam")
	//pcam:SetOwner(ply)
	//pcam:Spawn()
	//ply:SetNWEntity("pcam", pcam) 

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

--no gravity on props
local function Init_TriggerLogic()
	physenv.SetGravity( Vector( 0, 0, 0 ) )
end
hook.Add( "InitPostEntity", "MapStartTrigger", Init_TriggerLogic )