/*
This file makes the pcam visible for debug
*/
--includes
include("shared.lua")

function ENT:Draw()
	ply = self.Entity:GetOwner()
	if (GetConVar("planetview_debug"):GetInt() == 1  &&  ply == LocalPlayer()) then
		self.Entity:SetModel( "models/props_junk/sawblade001a.mdl" )
		self:DrawModel()
		return true
	end
	return false
end