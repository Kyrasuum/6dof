/*
This file creates a debug box for the AABB box
This file makes the pcam visible for debug
*/
--includes
include("shared.lua")

function ENT:RenderOverride()
	if (GetConvar("planetview_debug"):GetInt() == 1 ) then
		self:DrawModel()
		
		local ply = self.Entity:GetOwner()
		local min, max = ply:GetPhysicsObject():GetAABB()
		
		//Axis-Oriented Bounding box
		//Creating vectors for each point
		local aaa = min
		local aab = vector(min.x, min.y, max.z)
		local abb = vector(min.x, max.y, max.z)
		local aba = vector(min.x, max.y, min.z)
		local bab = vector(max.x, min.y, max.z)
		local baa = vector(max.x, min.y, min.z)
		local bba = vector(max.x, max.y, min.z)
		local bbb = max
		
		//12 lines make up a cube
		//min corner
		render.DrawLine(aaa, aab, Color( 0, 255, 0, 255 ), false)
		render.DrawLine(aaa, baa, Color( 0, 255, 0, 255 ), false)
		render.DrawLine(aaa, aba, Color( 0, 255, 0, 255 ), false)
		//max corner
		render.DrawLine(bbb, bba, Color( 0, 255, 0, 255 ), false)
		render.DrawLine(bbb, bab, Color( 0, 255, 0, 255 ), false)
		render.DrawLine(bbb, abb, Color( 0, 255, 0, 255 ), false)
		//remaining lines
		render.DrawLine(aab, abb, Color( 0, 255, 0, 255 ), false)
		render.DrawLine(aab, bab, Color( 0, 255, 0, 255 ), false)
		
		render.DrawLine(baa, bab, Color( 0, 255, 0, 255 ), false)
		render.DrawLine(baa, bba, Color( 0, 255, 0, 255 ), false)
		
		render.DrawLine(aba, bba, Color( 0, 255, 0, 255 ), false)
		render.DrawLine(aba, abb, Color( 0, 255, 0, 255 ), false)
	end
end