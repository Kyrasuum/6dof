/*
This file makes the pcam visible for debug
*/
--includes
include("shared.lua")
//--------------------------------------------------------------------------
//Create debug bounding box
//--------------------------------------------------------------------------
function ENT:Draw()
	ply = self.Entity:GetOwner()
	if !ply || !IsValid(ply) then return end
	if (GetConVar("planetview_debug"):GetInt() == 1  &&  ply == LocalPlayer()) then
		self:DrawModel()

		self.Entity:SetRenderBounds( Vector(-1000,-1000,-1000), Vector(1000,1000,1000) )

		render.SetColorMaterial()
		for i=0,ply:GetBoneCount() - 1,1 do
			local pos, ang = ply:GetBonePosition( i )
			if ( ply:BoneHasFlag(i,BONE_USED_BY_HITBOX) ) then
				render.DrawSphere( pos, 1, 50, 50, Color( 255, 0, 0, 255 ) )
			end
		end

		return true
	end
	return false
end