ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.PrintName		= "Mesh"
ENT.Author			= "Oochitecht"
ENT.Contact			= "Don't"
ENT.Purpose			= "Collision"
ENT.Instructions	= "Don't use"

//performs neccesary backend initialization
function ENT:Initialize()
	//stuff
end

function ENT:Use( activator, caller )
    //return
end
 
function ENT:Think()
	//server only
	if CLIENT then return end
	//first check if our mesh has propogated
	local size = self.Entity:GetNWInt("size")
	if size > 0 then
		//copy over mesh data
		local verts = {}
		for i = 1, size do
			verts[i] = self.Entity:GetNetworkedVector("vec"..tostring(i))
		end
		
		if IsValid(self.Entity:GetPhysicsObject()) then
			self.Entity:PhysicsDestroy()
		end

		self.Entity:PhysicsInitConvex(verts)
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:EnableCustomCollisions( true )
		self.Entity:EnableConstraints( true )
		self.Entity:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )

		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableGravity(true)
		end
		return
	end
end