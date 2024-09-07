/*
This File handles the player spawning and authentication
Good hooks for server side edits
*/
AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include( 'specialchars.lua' )
//Network cacheing
util.AddNetworkString( "View" )
util.AddNetworkString( "Sound" )
util.AddNetworkString( "atmos_settings" );
util.AddNetworkString( "atmos_lightmaps" );
util.AddNetworkString( "atmos_storm" );
util.AddNetworkString( "atmos_snow" );
util.AddNetworkString( "atmos_message" );


/*//==================================================================================////
								Atmos Intergration begins here                              
-- *///==================================================================================////	
-- Think = function( self )
-- 		-- lazy math inbound
-- 		if ( atmos_weather:GetInt() > 0 and self.m_NextWeatherCheck < CurTime() and ( cur == DAY or cur == DUSK ) ) then
-- 			if ( !self:GetStorming() and !self:GetSnowing() ) then
-- 				local rnd = math.random( 1, 100 );
-- 				local chance = atmos_weather_chance:GetInt();

-- 				if ( chance != 0 and rnd <= chance ) then
-- 					local snowChance = math.random( 1, 2 );

-- 					if ( atmos_snowenabled:GetInt() <= 0 ) then
-- 						snowChance = 0;
-- 					end

-- 					if ( snowChance == 1 ) then
-- 						self:StartSnow();
-- 					else
-- 						self:StartStorm();
-- 					end
-- 				end
-- 				self.m_NextWeatherCheck = CurTime() + atmos_weather_delay:GetInt();
-- 			end
-- 		end

-- 		if ( self:GetStorming() or self:GetSnowing() ) then
-- 			if ( self.m_WeatherEnd < CurTime() ) then
-- 				if ( self:GetStorming() ) then
-- 					self:StopStorm();
-- 				else
-- 					self:StopSnow();
-- 				end
-- 			end

-- 			if ( self:GetStorming() ) then
-- 				if ( ( self.m_Time > TIME_MIDNIGHT and self.m_Time < TIME_DAWN_START ) or ( self.m_Time >= TIME_DUSK_END ) ) then
-- 					cur = STORM_NIGHT;
-- 					next = STORM_NIGHT;
-- 				else
-- 					cur = STORM;
-- 					next = STORM;
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- function StartSnow( )
-- 	atmos_log( "Starting snow" );

-- 	self.m_Snowing = true;
-- 	self.m_NextWeatherCheck = 0;
-- 	self.m_WeatherEnd = CurTime() + atmos_weather_length:GetInt();

-- 	net.Start( "atmos_snow" );
-- 		net.WriteBool( true );
-- 	net.Broadcast();
-- end

-- function StopSnow( )
-- 	atmos_log( "Stopping snow" );

-- 	self.m_Snowing = false;
-- 	self.m_NextWeatherCheck = CurTime() + atmos_weather_delay:GetInt();
-- 	self.m_WeatherEnd = 0;

-- 	net.Start( "atmos_snow" );
-- 		net.WriteBool( false );
-- 	net.Broadcast();
-- end

-- function StartStorm( )

-- 	atmos_log( "Starting storm" );

-- 	self.m_Storming = true;
-- 	self.m_NextWeatherCheck = 0;
-- 	self.m_WeatherEnd = CurTime() + atmos_weather_length:GetInt();

-- 	if ( !( ( self.m_Time > TIME_MIDNIGHT and self.m_Time < TIME_DAWN_START ) or ( self.m_Time >= TIME_DUSK_END ) ) ) then
-- 		if ( atmos_weather_lightstyle:GetInt() > 0 ) then
-- 			self:LightStyle( "d", true );
-- 		end

-- 	end

-- 	if ( IsValid( self.m_EnvSkyPaint ) ) then
-- 		self.m_Cloudy = true;
-- 		self.m_EnvSkyPaint:SetStarTexture( "skybox/clouds" );
-- 	end

-- 	if ( IsValid( self.m_EnvSun ) ) then
-- 		self.m_EnvSun:Fire( "TurnOff", "", 0 );
-- 		if ( IsValid( self.m_EnvSkyPaint ) ) then
-- 			self.m_EnvSkyPaint:SetSunSize( 0 );
-- 		end
-- 		atmos_log( "Hiding sun" );

-- 	end

-- 	net.Start( "atmos_storm" );
-- 		net.WriteBool( true );
-- 	net.Broadcast();

-- end

-- function StopStorm( )

-- 	atmos_log( "Stopping storm" );

-- 	self.m_Storming = false;
-- 	self.m_NextWeatherCheck = CurTime() + atmos_weather_delay:GetInt();
-- 	self.m_WeatherEnd = 0;
-- 	self.m_Cloudy = false;

-- 	if ( IsValid( self.m_EnvSkyPaint ) ) then
-- 		self.m_EnvSkyPaint:SetStarTexture( "skybox/starfield" );
-- 	end

-- 	if ( !( ( self.m_Time > TIME_MIDNIGHT and self.m_Time < TIME_DAWN_START ) or ( self.m_Time >= TIME_DUSK_END ) ) ) then
-- 		if ( IsValid( self.m_EnvSun ) ) then
-- 			self.m_EnvSun:Fire( "TurnOn", "", 0 );
-- 			atmos_log( "Showing sun" );
-- 		end

-- 	end

-- 	net.Start( "atmos_storm" );
-- 		net.WriteBool( false );
-- 	net.Broadcast();

-- 	local style = self.m_LastStyle;

-- 	if ( atmos_weather_lightstyle:GetInt() > 0 ) then
-- 		self:LightStyle( style, true );
-- 	end
-- end

-- function AtmosMessage( pl, ... )
-- 	net.Start( "atmos_message" );
-- 		net.WriteTable( { ... } );
-- 	net.Send( pl );
-- end

-- function AtmosMessageAll( ... )
-- 	net.Start( "atmos_message" );
-- 		net.WriteTable( { ... } );
-- 	net.Broadcast();
-- end

/*//==================================================================================////
								Planetview server side begins here                            
*///==================================================================================////
hook.Add("Think","GmThink",function( self )
	if theta != nil && sun != nil && shade != nil then 
		theta = theta - 0.01
		sunang = Angle(theta,0,0)

		sun:SetAngles( sunang )
		sun:Activate()

		shade:Fire( "SetAngles", (-sunang.pitch).." "..( sunang.yaw + 180 ).." "..sunang.roll, 0 )
		shade:Activate()

		lamp:SetPos(sunang:Forward() * 1700)
	end
end)


//Init database
hook.Add("Initialize","GmInit",function()
	tables_exist()
end)

--no gravity on props
hook.Add("InitPostEntity","InitPostEntityGM",function()
	src = NULL
	ent,range = FindNearestEntity( "planetphys", src, 16384 )
	if(IsValid(ent))then
		GetConVar("planetview_enabled"):SetInt(1)
	end

	if (GetConVar("planetview_enabled"):GetInt() == 1) then
		physenv.SetGravity( Vector( 0, 0, 0 ) )
		physenv.SetAirDensity( 0 )
	end

	if !IsValid(lamp) then
		lamp = ents.Create( "gmod_light" )
		lamp:SetColor( Color( 255, 255, 255, 255 ) )
		lamp:SetBrightness( 3 )
		lamp:SetLightSize( 100000000 )
		lamp:SetOn( true )
		lamp:Spawn()

		lamp:SetCollisionGroup(COLLISION_GROUP_WORLD)
		lamp:SetMaterial("")
		lamp:SetRenderMode(RENDERMODE_TRANSALPHA)
	    lamp:GetPhysicsObject():EnableMotion(false)
	end

	sun = ents.FindByClass( "edit_sun" )[1]
	if !IsValid(sun) then
		sun = ents.Create( "edit_sun" )
		sun:Spawn()
	end
	sun:SetCollisionGroup(COLLISION_GROUP_WORLD)
    sun:SetColor(Color(255,255,255,0))
    sun:SetRenderMode(RENDERMODE_TRANSCOLOR)
    sun:GetPhysicsObject():EnableMotion(false)

	shade = ents.FindByClass( "shadow_control" )[1]
	if !IsValid(shade) then
		shade = ents.Create( "shadow_control" )
		shade:Spawn()
	end

	theta = 0
end)

//Called on each player spawn
hook.Add("PlayerSpawn","PlayerSpawnGM",function( ply )
	ply:SetAllowWeaponsInVehicle( true )

	///*PCAM testing code
	-- ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	-- ply:SetColor( Color(0, 0, 0, 0 ) )

	--[[ if (ply:Team() > 1) then
		if ply:GetNetworkedEntity("plycam") && IsValid( ply:GetNetworkedEntity("plycam") ) then 
			ply:GetNetworkedEntity("plycam"):Remove()
		end
		
		local pcam = ents.Create("pcam")
		pcam:SetPos(ply:GetPos())
		pcam:SetAngles(ply:GetAngles())
		pcam:SetOwner(ply)
		pcam:Spawn()
		ply:SetNetworkedEntity("plycam", pcam)
	end--]] 

	//Player rotation manip
	ply:SetNetworkedAngle( "RotAng", Angle(0,0,0) )

    ply:SetWalkSpeed( 325 )  
	ply:SetRunSpeed( 325 )

	if (GetConVar("planetview_enabled"):GetInt() == 1) then
		ply:SetGravity( 0.00001 )
	end
end)

//Called on initial player spawn only
hook.Add( "PlayerInitialSpawn", "InitialSpawnGM", function( pl )
	//nothing
end );
 
//User Authentication parsing
hook.Add("PlayerAuthed","PlayerAuthedGM",function( ply, stid, unid )
	RunConsoleCommand( "sb_start" )
	ply:SetTeam(1)
	ply:Spectate( 5 )
end)

//Restrict some weapons
hook.Add("PlayerLoadout","PlayerLoadoutGM",function( ply )
	ply:StripWeapons()
	if (ply:Team() >= 2) then //Guest
        ply:Give( "swep_physgun" )
		ply:Give( "swep_gravgun" )
		ply:Give( "gmod_tool" )
    end
	if (ply:Team() >= 3) then //Member
		ply:Give( "swep_pistol" )
		ply:Give( "swep_smg1" )
		ply:Give( "swep_crowbar" )
	 
		ply:GiveAmmo( 999, "pistol" )
		ply:GiveAmmo( 999, "smg1" )
    end
	if (ply:Team() >= 4) then //Admin+
		ply:Give( "swep_frag" )
		ply:Give( "swep_crossbow" )
		ply:Give( "swep_shotgun" )
		ply:Give( "swep_357" )
		ply:Give( "swep_rpg" )
		ply:Give( "swep_ar2" )
	    //ply:Give( "gmod_camera" )
    end
    return true
end)

//Used on initial spawn
function unspectate( ply )
	ply:UnSpectate()

	player_exists( ply ) 
end
concommand.Add( "unspectate", unspectate )

//Needed to sync shooting
net.Receive( "View", function( len, ply )
	//Store it for outside access
	ply:SetNWVector("origin", net.ReadVector())
	ply:SetNWAngle("angles", net.ReadAngle())
end )

//Space chat rules
hook.Add("PlayerCanSeePlayersChat","PlayerCanSeePlayersChatGM",
	function( txt, bool, tar, src )
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
)

//We process fall damage within collision.  A seperate calc here is not needed.
hook.Add("GetFallDamage","GetFallDamageGM",function( ply, speed )
	return ( 0 )
end)

//Space sound function
hook.Add("EntityEmitSound","EntityEmitSoundGM",function( data )
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
end)

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
			return self.BaseClass:PlayerSpawnProp( ply, mdl )//The model is whitelisted
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
			return self.BaseClass:PlayerSpawnEffect( ply, mdl )//The model is whitelisted
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
			return self.BaseClass:PlayerSpawnNPC( ply, npc, weapon )//The model is whitelisted
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
			return self.BaseClass:PlayerSpawnRagdoll( ply, mdl, ent )//The model is whitelisted
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
			return self.BaseClass:PlayerSpawnVehicle( ply, mdl, name, tab )//The model is whitelisted
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
			tab.AccurateCrosshair = true
			return self.BaseClass:PlayerSpawnVehicle( ply, wep, tab )//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. wep);
	return false//You cant spawn this
end
function GM:PlayerSpawnSWEP( ply, wep, tab )
	if (ply:IsAdmin()) then return true end
	for _, v in pairs( weapon ) do
		if string.find( mdl, v ) then
			tab.AccurateCrosshair = true
			return self.BaseClass:PlayerSpawnSWEP( ply, wep, tab )//The model is whitelisted
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
			return self.BaseClass:PlayerSpawnSENT( ply, mdl )//The model is whitelisted
		end
	end
	ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to spawn " .. mdl);
	return false//You cant spawn this
end