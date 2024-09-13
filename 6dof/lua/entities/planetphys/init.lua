AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.ptype = "planet"
	self.smin = 0
	self.smax = 1
	self.gmax = 2
	self.gmul = 1
	self.atmos = 0
end

function ENT:KeyValue( key, value )
	if ( key == "type" ) then
		self.ptype = value || "planet"
	end
	if ( key == "surface min" ) then
		self.smin = tonumber(value,10) || 1
	end
	if ( key == "surface max" ) then
		self.smax = tonumber(value,10) || 1
	end
	if ( key == "grav max" ) then
		self.gmax = tonumber(value,10) || 1
	end
	if ( key == "grav multiplier" ) then
		self.gmul = tonumber(value,10) || 1
	end
	if ( key == "atmosphere radius" ) then
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
	for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.gmax)) do
		ent:SetVelocity(ent:GetVelocity() + CalcGravVel(ent, {self}))
	end
end

function ENT:OnRemove()
end