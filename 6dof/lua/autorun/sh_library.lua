AddCSLuaFile()

local PLAYER = FindMetaTable("Player") --Get the meta table of player
local ENTITY = FindMetaTable("Entity") --Get the meta table of entity

function PLAYER:InAtmosphere()
	ent, range = FindNearestGravBody( self, 65535 )
    if range > ent.atmos then
		self:SetDSP(31) -- Space effect
    	return false
    else
		self:SetDSP(1) -- Normal effect
    	return true
    end
end

function ENTITY:InAtmosphere()
	ent, range = FindNearestGravBody( self, 65535 )
    if range > ent:GetTable().atmos then
    	return false
    else
    	return true
    end
end

function FindNearestEntity( className, src, range )
    -- finds the nearest entity of given class from src object up to a max distance
	if (!IsValid(src)) then return nil, 0 end
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

-- tracking planetphys objects to speed up calculations a bit
local GravBodies = {}
hook.Add( "OnEntityCreated", "GravBodiesList", function( ent )
	if( ent:GetClass() != "planetphys" || !ent:IsValid() ) then return end
    -- check if init done yet
    InitGravBodies()
    -- add to list
	GravBodies[#GravBodies+1] = ent

    -- cleanup function when entity is removed
    ent:CallOnRemove("GravBodiesClean", function( ent )
        for i, v in ipairs( GravBodies ) do
            if v == ent then
                table.remove( GravBodies, i )
            end
        end
    end )
end )

function InitGravBodies()
    if ( #GravBodies == 0 ) then
        GravBodies = ents.FindByClass( "planetphys" )
    end
end

function FindNearestGravBody( src, range )
	if (!IsValid(src)) then return nil, 0 end
    -- check if init done yet
    InitGravBodies()

    -- finds the nearest gravity body from src object up to a max distance
    local nearestEnt;
    for i, entity in ipairs( GravBodies ) do
        local distance = src:GetPos():Distance( entity:GetPos() );
        if( distance <= range && src != ent ) then
            nearestEnt = entity;
            range = distance; 
        end
    end
    return nearestEnt, range;
end

function CalcGravVel( obj, planets )
    -- calculate the velocity to apply due to gravity
    local grav = Vector()
    if( planets == nil ) then
        planets = GravBodies
    end

    for _, planet in ipairs( planets ) do
        local offset = obj:GetPos() - planet:GetPos()
        local dist = offset:Length()
        offset:Normalize()

        local gmax = planet.gmax
        if( dist > gmax ) then
            continue
        end

        local gmul = planet.gmul
        local smax = planet.smax
        local smin = planet.smin

        local falloff = math.min(1, (gmax-dist)/(gmax-smax), dist/smin)
        grav = grav + offset*gmul*falloff
    end
    return grav
end