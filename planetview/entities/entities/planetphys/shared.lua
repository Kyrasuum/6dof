/*
Declaritive statements for the entity
sets up the entities values
*/
--basic entity declarations
ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName		= "planet phys"
ENT.Author			= "Oochitecht"
ENT.Contact			= "NovelUpdates.com"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

AddCSLuaFile( "shared.lua" )

//grab values from map
function ENT:KeyValue( key, value )
	if ( key == "type" ) then
		self:SetNWString("type",value)
	end
	if ( key == "radius" ) then
		self:SetNWInt("radius",tonumber(value,10))
	end
	if ( key == "mass" ) then
		self:SetNWInt("mass",tonumber(value,10))
	end
	if ( key == "atmosphere" ) then
		self:SetNWInt("atmosphere",tonumber(value,10))
	end
	if ( key == "Name" ) then
		self:SetName(value)
	end
	if ( key == "parent" ) then
		self:SetParent(value)
	end
end

function ENT:OnRemove()
  --nothing to do yet
end