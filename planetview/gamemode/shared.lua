/*
This File contains library functions, overrides, or other
reference material to support server and client.
*/
//Scoreboard includes
include( "qmod/qmod.lua" )


//defines
GM.Name		= "planetview"
GM.Author	= "Architecht, Fang"
GM.Email	= "Oochitecht@gmail.com"
GM.Website	= "breadfish.co.uk"
DeriveGamemode( "sandbox" )

GM.AllowAutoTeam = false
GM.AllowSpectating = true

function ChangeMyTeam( ply, cmd, args )
	local _team = args[ 1 ] && tonumber( args[ 1 ] ) || 0;
	ply:SetTeam( _team );
	ply:Spawn( );
end
concommand.Add( "set_team", ChangeMyTeam );

//teams
team.SetUp( 1, "Joining", Color( 0, 0, 0, 255) ) 
team.SetUp( 2, "Guest", Color( 255, 50, 50, 255) ) 
team.SetUp( 3, "Member", Color( 200, 10, 10, 255) ) 
team.SetUp( 4, "Admin", Color( 50, 50, 255, 255) ) 
team.SetUp( 5, "SuperAdmin", Color( 10, 10, 200, 255) ) 
team.SetUp( 6, "Owner", Color( 255, 255, 255, 255) ) 

function GM:GetGameDescription()
	return "Planetview is a child of spacebuild featuring realistic spherical planets"
end

//Decides if we should play (falling) animation
function GM:HandlePlayerVaulting( ply, vel )
	//maybe do more stuff later
	return false
end

//Decides if we should play (noclip) animation
function GM:HandlePlayerNoClipping( ply, vel )
	//maybe do more stuff later
	return false
end

--no flying for guests
function GM:PlayerNoClip( ply, toggle )
	//Only admin can noclip
	if ply:IsAdmin() then
		if toggle then
			//change movement type
			ply:SetMoveType( MOVETYPE_NOCLIP )
			ply:SetAllowFullRotation(false)
		else
			//change movement type
			ply:SetMoveType( MOVETYPE_VPHYSICS )
			ply:SetAllowFullRotation(true)
		end
	else
		ply:PrintMessage(HUD_PRINTCENTER,"You're not allowed to noclip");
	end
	return false//Never do normal noclip
end

//--------------------------------------------------------------------------
//Library functions for rotating players view
//--------------------------------------------------------------------------
function CalcRotation( ply, Origin, EyeAng )
	//Checking values
	if (!IsValid(ply)) then return end
	if (!IsValid(Origin)) then Origin = ply:RealEyePos() end
	if (!IsValid(EyeAng)) then EyeAng = ply:RealEyeAngles() end

	//Calc Variables
	local PlanetPos = GetPlanetPos(ply)
	local LocalPos = (ply:RealGetPos()-PlanetPos)
	local RollAng = Vector(-LocalPos.y,math.abs(LocalPos.z),0):AngleEx(Vector(0,0,0)).y -90
	local PitchAng = Vector(-LocalPos.x,LocalPos.z,0):AngleEx(Vector(0,0,0)).y -90
	local PosAng = Angle(PitchAng,0,-RollAng)
	local _,CorrecAng = LocalToWorld(Origin,Angle(0,EyeAng.y,0),Origin,PosAng)

	local eyeOff = (ply:RealEyePos() - ply:RealGetPos()):Length()
		
	//Output
	local _,Angles = LocalToWorld(Origin,Angle(EyeAng.p,0,0),Origin,CorrecAng)
	local Origin = CorrecAng:Up()
	Origin:Mul(eyeOff)
	Origin:Add( ply:RealGetPos() )
	
	//If we should be pointing somewhere
	if (ply.OffAng != nil && ply.HoldAng == 1) then
		Angles = ply.OffAng
	else
		ply.OffAng = Angle(0,0,0)	//Stores angle to point at
		ply.HoldAng = 0				//used as a toggle
	end
	
	return Angles, Origin, CorrecAng, PosAng //New Eye Angles, New Eye Pos, New Normal
end

//--------------------------------------------------------------------------
//library function for nearest entity
//--------------------------------------------------------------------------
function FindNearestEntity( className, src, range )
	if (!IsValid(src)) then return src end
    local nearestEnt;
    for i, entity in ipairs( ents.FindByClass( className ) ) do
        local distance = src:GetPos():Distance( entity:GetPos() );
        if( distance <= range ) then
            nearestEnt = entity;
            range = distance; 
        end
    end
    return nearestEnt, range;
end

//--------------------------------------------------------------------------
//library function for checking if in atmosphere
//--------------------------------------------------------------------------
function InAtmosphere( src )
	ent,range = FindNearestEntity( "planetphys", src, GetConVar("planetview_playerGravRange"):GetInt() )
	//Update sound effects
    if range > ent:GetTable().atmos then
    	if (src:IsPlayer()) then
    		src:SetDSP(31)//Space effect
    	end
    	return false
    else
    	if (src:IsPlayer()) then
    		src:SetDSP(1)//Normal effect
    	end
    	return true
    end
end

//--------------------------------------------------------------------------
//Library function for planet pos
//--------------------------------------------------------------------------
function GetPlanetPos( src )
	if (!IsValid(src)) then return Vector(0,0,0) end
	local ent = FindNearestEntity( "planetphys", src, GetConVar("planetview_playerGravRange"):GetInt() )
	if (ent != nil && ent != NULL ) then
		return ent:GetPos()
	else
		return src:GetPos()
	end
end

function GM:Initialize()
	//Convars
	CreateConVar("planetview_gravConst", 0.00000000006674)//This scales all gravity interaction
	CreateConVar("planetview_playerMass", 1)//how heavy is player
	CreateConVar("planetview_playerGravRange", 16834)//how far does player search for a nearby planet
	CreateConVar("planetview_debug", 0)//prints messages and makes debugging models visable
	CreateConVar("planetview_chatDist", 10)//Coefficent for how far should player chat be fine
end

//Player death here
hook.Add("DoPlayerDeath", "drop weapon after death", function(ply)
	ply:ShouldDropWeapon(true);
end);
 
hook.Add("PlayerDeath", "drop weapon after death", function(ply)
	ply:ShouldDropWeapon(false);
end);
/*//==================================================================================////
									Overriding Functions Here
								Grav Hull Designator inspired pattern
*///==================================================================================////
_R = debug.getregistry()

//Storing the orginals
//Getters
if !_R.Player.RealShootPos then
	_R.Player.RealShootPos = _R.Player.GetShootPos
end

if !_R.Player.RealGetAimVector then
	_R.Player.RealGetAimVector = _R.Player.GetAimVector
end

if !_R.Entity.RealEyePos then
	_R.Entity.RealEyePos = _R.Entity.EyePos
end

if !_R.Entity.RealEyeAngles then
	_R.Entity.RealEyeAngles = _R.Entity.EyeAngles
end

if !_R.Entity.RealGetPos then
	_R.Entity.RealGetPos = _R.Entity.GetPos
end

if !_R.Entity.RealGetAngles then
	_R.Entity.RealGetAngles = _R.Entity.GetAngles
end

if !_R.Entity.RealIsOnGround then
	_R.Entity.RealIsOnGround = _R.Entity.IsOnGround
end

if !_R.Entity.RealOnGround then
	_R.Entity.RealOnGround = _R.Entity.OnGround
end
//Setters
if !_R.Player.RealSetEyeAngles then
	_R.Player.RealSetEyeAngles = _R.Player.SetEyeAngles
end
if !_R.Entity.RealSetAngles then
	_R.Entity.RealSetAngles = _R.Entity.SetAngles
end
//-------------------------------------------------------
//New functions------------------------------------------
//-------------------------------------------------------
//Getters

function _R.Player:GetMass()
	 return GetConVar("planetview_playerMass"):GetInt()
end

function _R.Player:GetMassCenter()
	 return Vector(0,0,0)
end

function _R.Player:GetShootPos()
	return self:GetNWVector("origin") or self:RealGetShootPos()
end

function _R.Player:GetAimVector()
	return self:GetNWAngle("angles"):Forward() or self:RealGetAimVector()
end

function _R.Entity:EyePos()
	return self:GetNWVector("origin") or self:RealEyePos()
end

function _R.Entity:EyeAngles()
	return self:GetNWAngle("angles") or self:RealEyeAngles()
end

function _R.Entity:GetPos()
	return self:RealGetPos() or self:RealGetPos()
end

function _R.Entity:GetAngles()
	if (self:IsPlayer() && self:GetMoveType() == MOVETYPE_NOCLIP) then 
		return self:GetNWAngle("angles") or self:RealGetAngles()
	end

	return self:RealGetAngles()
end
/*Do later
function _R.Entity:IsOnGround()
	
end

function _R.Entity:OnGround()
	
end
*/
//Setters
function _R.Player:SetEyeAngles( ang )
	//We dont know if they are using real values to set this.  Can be dangerious
	self:RealSetEyeAngles( ang )
end

function _R.Entity:SetAngles( ang )
	if (!ang || !IsValid(ang)) then return Angle(0,0,0) end
	if (!self:IsPlayer()) then self:RealSetAngles( ang ) end
end
//Permissions
function _R.Player:IsAdmin()
	return (self:Team() > 3)
end

function _R.Player:IsSuperAdmin()
	return (self:Team() > 4)
end

function _R.Player:IsOwner()
	return (self:Team() == 6)
end