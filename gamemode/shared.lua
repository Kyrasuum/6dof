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

//teams
team.SetUp( 1, "Guest", Color( 148, 0, 211), true ) 

--no flying for guests
function GM:PlayerNoClip( ply, toggle )
	if ply:IsAdmin() || ply:IsSuperAdmin() then
		if (toggle) then
			//Make sure we properly exit
			GetConVar("planetview_view_enable"):SetInt(1)
			ply:GetNWEntity("pcam"):GetTable():FinRotation()
		else
			if (GetConVar("planetview_view_enable"):GetInt() == 1) then
				//Make sure we properly return
				GetConVar("planetview_view_enable"):SetInt(2)
				ply:GetNWEntity("pcam"):GetTable():InitRotation()
			end
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
	CreateConVar("planetview_view_enable", 0)//0 is disabled; 1 is partially disabled; 2 is enabled
	CreateConVar("planetview_debug", 1)//prints messages and makes debugging models visable
end
hook.Add( "Initialize", "initializing", Init_Gamemode );

/*//==================================================================================////
									Overriding Functions Here
								Grav Hull Designator inspired pattern
*///==================================================================================////
local PLY = FindMetaTable("Player")

//Storing the orginals
//Placeholder (work on later)
if !util.RealPlayerTrace then
	util.RealPlayerTrace = util.GetPlayerTrace
end
//Placeholder (work on later)
if !util.RealTraceLine then
	util.RealTraceLine = util.TraceLine
end

if !PLY.RealEyeTrace then
	PLY.RealEyeTrace = PLY.GetEyeTrace
end

if !PLY.RealEyeTraceNoCursor then
	PLY.RealEyeTraceNoCursor = PLY.GetEyeTraceNoCursor
end

if !PLY.RealShootPos then
	PLY.RealShootPos = PLY.GetShootPos
end

if !PLY.RealAimVector then
	PLY.RealAimVector = PLY.GetAimVector
end
//Not sure if this is right
function PLY:GetEyeTrace(hax,real)
	if ( self.LastPlayerTrace == CurTime() && self.LastTraceWasReal == real && self.LastTraceWasHax == hax) then
		return self.PlayerTrace
	end
	
	local data
	self.PlayerTrace = util.TraceLine{ start = self.view.origin, endpos = self.view.origin:Add(self:GetAimVector() * (16834)), filter = self}
	self.LastPlayerTrace = CurTime()
	self.LastTraceWasReal = real
	self.LastTraceWasHax = hax
	
	return self.PlayerTrace
end
//Not sure if this is right
function PLY:GetEyeTraceNoCursor()
	return self:GetEyeTrace(true)
end

function PLY:GetShootPos()
	return util.TraceLine{ start = self.view.origin, endpos = self.view.origin:Add(self:GetAimVector() * (16834)), filter = self}.HitPos
end

function PLY:GetAimVector()
	return self.view.angles:Forward()
end