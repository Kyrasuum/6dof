AddCSLuaFile()

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