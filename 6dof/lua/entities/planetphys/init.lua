AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:KeyValue( key, value )
	if ( key == "type" ) then
		self.ptype = value || "planet"
	end
	if ( key == "radius" ) then
		self.prad = tonumber(value,10) || 1
	end
	if ( key == "mass" ) then
		self.pmass = tonumber(value,10) || 1
	end
	if ( key == "atmosphere" ) then
		self.atmos = tonumber(value,10) || prad
	end
	if ( key == "Name" ) then
		self:SetName(value)
	end
	if ( key == "parent" && value != nil && type(value)=="Entity" ) then
		self:SetParent(value)
	end
end

function ENT:Think()
end

function ENT:OnRemove()
end