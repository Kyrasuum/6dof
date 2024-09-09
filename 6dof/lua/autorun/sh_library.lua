AddCSLuaFile()

local PLAYER = FindMetaTable("Player") --Get the meta table of player
local ENTITY = FindMetaTable("Entity") --Get the meta table of entity

function PLAYER:InAtmosphere()
	ent, range = FindNearestGravBody( self, 65535 )
    if range > ent:GetTable().atmos then
		src:SetDSP(31) -- Space effect
    	return false
    else
		src:SetDSP(1) -- Normal effect
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