/*
This File handles the player spawning and authentication
Good hooks for server side edits
*/
AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" )
//Scoreboard
AddCSLuaFile( "qmod/qmod.lua" )

include( 'shared.lua' )
include( 'specialchars.lua' )
//Network cacheing
util.AddNetworkString( "View" )
util.AddNetworkString( "Sound" )
 
//Init database
hook.Add( "Initialize", "Initialize", function()
	//sql.Query("DROP TABLE player_info")//flushes the data
	tables_exist()
end )
 
//User Authentication parsing
function GM:PlayerAuthed( ply, stid, unid )
	RunConsoleCommand( "sb_start" )
	ply:SetTeam(1)
	ply:Spectate( 5 )
end

//Restrict some weapons
function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	if (ply:Team() >= 2) then //Guest
		/*
        ply:Give( "weapon_physcannon" )
		ply:Give( "weapon_physgun" )
		ply:Give( "gmod_tool" )
		*/
    end
	if (ply:Team() >= 3) then //Member
		/*
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_smg1" )
		ply:Give( "weapon_crowbar" )
	 
		ply:GiveAmmo( 999, "pistol" )
		ply:GiveAmmo( 999, "smg1" )
		*/
    end
	if (ply:Team() >= 4) then //Admin+
		/*
		ply:Give( "weapon_frag" )
		ply:Give( "weapon_crossbow" )
		ply:Give( "weapon_shotgun" )
		ply:Give( "weapon_357" )
		ply:Give( "weapon_rpg" )
		ply:Give( "weapon_ar2" )
	    ply:Give( "gmod_camera" )
		*/
    end
end

//Used on initial spawn
function unspectate( ply ) 
	ply:UnSpectate()
	ply:Spawn()

	player_exists( ply ) 
end
concommand.Add( "unspectate", unspectate )
 
//Called on each player spawn
function GM:PlayerSpawn(ply)
    self.BaseClass:PlayerSpawn(ply)
	ply:SetAllowWeaponsInVehicle( true )

	//ply:SetMoveType( MOVETYPE_VPHYSICS )
	
    ply:SetGravity( 0.00001 )
    ply:SetWalkSpeed( 325 )  
	ply:SetRunSpeed( 325 )
end

--no gravity on props
function GM:InitPostEntity()
	physenv.SetGravity( Vector( 0, 0, 0 ) )
	physenv.SetAirDensity( 0 )
end

//Needed to sync shooting
net.Receive( "View", function( len, ply )
	//Store it for outside access
	ply:SetNWVector("origin", net.ReadVector())
	ply:SetNWAngle("angles", net.ReadAngle())
end )

//Space chat rules
function GM:PlayerCanSeePlayersChat( txt, bool, tar, src )
	local tab = {}
	//from dead dude
	if ( !src:Alive() ) then
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
		else
			//Scaling by distance
			local vol = 100
			local vol = vol - math.abs( 20 * math.log10( 1 / ( tar:GetPos() -
				src:GetPos() ):Length() ) ) / GetConVar( "planetview_chatDist" ):GetInt()
			if (vol <= 0) then return false end
			local tbl = string.ToTable( txt )
			for i = 0, string.len( txt ) do
				//interference based on distance
				if ( math.random( 0,100 ) > vol ) then
					tbl[i] = '*'
				end
			end
			txt = table.ToString( tbl )
		end
	else
		//from console
		table.insert( tab, "Console" )
	end
	
	//Add their text
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..txt )
	
	//Should we be able to see this
	if ((tar:Team() == src:Team()) || !bool) then 
		chat.AddText( unpack( tab ) )
	end
	//Block normal chat
	return false
end

//We process fall damage within collision.  A seperate calc here is not needed.
function GM:GetFallDamage( ply, speed )
	return ( 0 )
end

//Space sound function
function GM:EntityEmitSound( data )
	if !IsValid(data.Entity) then return nil end
	//check if in space
	if !InAtmosphere(data.Entity) then
		data.DSP = 30
		if (constraint.HasConstraints( data.Entity )) then
			local tbl = constraint.GetAllConstrainedEntities( data.Entity )
			//send sound data to all clients
			net.Start( "Sound" )
				net.WriteTable( tbl )
				net.WriteTable( data )
			net.Broadcast()
		end
		//we handle sound client side
		return false
	end
	//in atmosphere, dont change anything
	return nil
end

/*//==================================================================================////
								Whitelisting is done here
*///==================================================================================////
//Tables of whitelisted items
local models = {}
local effect = {}
local npcs = {}
local ragdolls = {}
local vehicle = {}
local weapon = {}
local sent = {}

//Props
function GM:PlayerSpawnProp( ply, mdl )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( models ) do
		if string.find( mdl, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. mdl);
	return false//You cant spawn this
end
//Effects
function GM:PlayerSpawnEffect( ply, mdl )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( effect ) do
		if string.find( mdl, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. mdl);
	return false//You cant spawn this
end
//NPCS
function GM:PlayerSpawnNPC( ply, npc, weapon )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( npcs ) do
		if string.find( npc, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. npc);
	return false//You cant spawn this
end
//Ragdolls
function GM:PlayerSpawnRagdoll( ply, mdl, ent )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( ragdolls ) do
		if string.find( mdl, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. mdl);
	return false//You cant spawn this
end
//Vehicles
function GM:PlayerSpawnVehicle( ply, mdl, name, tab )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( vehicle ) do
		if string.find( mdl, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. mdl);
	return false//You cant spawn this
end
//SWEPs
function GM:PlayerGiveSWEP( ply, wep, tab )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( weapon ) do
		if string.find( wep, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. wep);
	return false//You cant spawn this
end

function GM:PlayerSpawnSWEP( ply, wep, tab )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( weapon ) do
		if string.find( mdl, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. mdl);
	return false//You cant spawn this
end
//SENTs
function GM:PlayerSpawnSENT( ply , mdl )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( sent ) do
		if string.find( mdl, v ) then
			return true//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. mdl);
	return false//You cant spawn this
end