
local meta = FindMetaTable( "PhysObj" )
if (!meta) then return end

// In this file we're adding functions to the physics object meta table.
// This means you'll be able to call functions here straight from the physics object
// You can even override already existing functions.

if ( !meta.SetAngleVelocity ) then

	function meta:SetAngleVelocity( velocity )

		self:AddAngleVelocity( -self:GetAngleVelocity() + velocity )

	end

end

