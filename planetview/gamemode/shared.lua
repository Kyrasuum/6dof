/*
This File contains library functions, overrides, or other
reference material to support server and client.
*/
//defines
GM.Name		= "planetview"
GM.Author	= "Architecht, Fang"
GM.Email	= "Oochitecht@gmail.com"
GM.Website	= "breadfish.co.uk"
DeriveGamemode( "sandbox" )

GM.AllowAutoTeam = false
GM.AllowSpectating = true

//teams
team.SetUp( 0, "Joining", Color( 0, 0, 0, 255) ) 
team.SetUp( 2, "Guest", Color( 255, 50, 50, 255) ) 
team.SetUp( 3, "Member", Color( 200, 10, 10, 255) ) 
team.SetUp( 4, "Admin", Color( 50, 50, 255, 255) ) 
team.SetUp( 5, "SuperAdmin", Color( 10, 10, 200, 255) ) 
team.SetUp( 6, "Owner", Color( 255, 255, 255, 255) ) 

--no flying for guests
function GM:PlayerNoClip( ply, toggle )
	if ply:IsAdmin() || ply:IsSuperAdmin() then
		if toggle then
			GetConVar("planetview_view_enable"):SetInt(0)
		else
			GetConVar("planetview_view_enable"):SetInt(1)
		end
		return true
	else return false
	end
end

//library function for nearest entity
local function FindNearestEntity( className, pos, range )
    local nearestEnt;
    for i, entity in ipairs( ents.FindByClass( className ) ) do
        local distance = pos:Distance( entity:GetPos() );
        if( distance <= range ) then
            nearestEnt = entity;
            range = distance; 
        end
    end
    return nearestEnt;
end

//Library function for planet pos
function GetPlanetPos( pos )
	ent = FindNearestEntity( "planetphys", pos, GetConVar("planetview_playerGravRange"):GetInt() )
	if (ent != nil && ent != NULL ) then
		return ent:GetPos()
	else
		return pos
	end
end

--Console variables
local function Init_Gamemode()
	CreateConVar("planetview_gravConst", 0.00000000006674)//This scales all gravity interaction
	CreateConVar("planetview_playerMass", 1)//how heavy is player
	CreateConVar("planetview_playerGravRange", 16834)//how far does player search for a nearby planet
	CreateConVar("planetview_view_enable", 0)//0 is disabled; 1 is enabled
	CreateConVar("planetview_debug", 1)//prints messages and makes debugging models visable
end
hook.Add( "Initialize", "initializing", Init_Gamemode );

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

function _R.Player:GetShootPos()
	return self:GetNWVector("origin") or self:RealGetShootPos()
end

function _R.Player:GetAimVector()
	return self:GetNWAngle("angles"):Forward()
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
	return self:GetNWAngle("angles") or self:RealGetAngles()
end

function _R.Player:SetEyeAngles( ang)
	
end

function _R.Entity:SetAngles( ang )

end