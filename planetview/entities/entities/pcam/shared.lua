/*
This file handles the physics interactions of pcam
*/
--basic entity declarations
ENT.Base 			= "base_anim"
ENT.Type 			= "anim"
ENT.PrintName		= "player camera"
ENT.Author			= "Oochitecht"
ENT.Contact			= "Steam.com"

--initialize (speaks for itself really)
function ENT:Initialize()
	ply = self:GetOwner()
	if !IsValid(ply) then self.Entity:Remove() end
	self.Entity.setup = 0 //stores if we ran initrotation
	self.Entity.const = nil //stores our player constraint
	-- self.Entity:SetModel( ply:GetModel() )
	self.Entity:SetModel( "models/props_junk/garbage_sodacan01a_fullsheet.mdl" ) 
	
	-- self.Entity:AddCallback("BuildBonePositions", pcamBones)
	-- if !SERVER then
	-- 	self.Entity:SetupBones()
	-- end
end
	/*
	local x0 = -16 -- Define the min corner of the box
	local y0 = -16
	local z0 = 0

	local x1 = 16 -- Define the max corner of the box
	local y1 = 16
	local z1 = 72

	-- Set up solidity and movetype
	self.Entity:SetSolid( SOLID_OBB )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetCollisionBounds(Vector( x0, y0, z0 ), Vector( x1, y1, z1 ))

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() --wake up the physics object so we can turn off collisions and gravity
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
		phys:EnableGravity(false)
		phys:SetMass(5000)
	else
		print("Error: NonValid PCam PhysObj")
	end
end

function pcamBones( ent, bones )
	local ply = ent:GetOwner() --get the player
	if (!IsValid(ply) || ply:GetBoneCount() != bones) then return end
	for i=0,bones,1 do
		pos, ang = ply:GetBonePosition(i)
		if IsValid(vMatrix) then
			ent:SetBonePosition(i,pos,ang)
		end
	end
end

//Setup player parented to Pcam
function ENT:InitRotation()
	local ply = self.Entity:GetOwner() --get the player
	if (!SERVER) then return end

	ply:SetMoveType(MOVETYPE_NONE)
	ply:SetLocalVelocity(Vector(0,0,0))
	self.Entity:StartMotionController()

	phys = self.Entity:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	//ply:SetParent(self.Entity)
	//Trying with a weld 
	self.Entity.const = constraint.Weld(ply,self.Entity,0,0,0,true,false)
	
	self.Entity.setup = 1
end

//Finish parenting
function ENT:FinRotation()
	local ply = self.Entity:GetOwner() --get the player
	if (!SERVER) then return end
	self.Entity:StopMotionController()
	//ply:SetParent(NULL)
	//Trying with a weld
	self.Entity.const:Remove()
	
	self.Entity.setup = 0
end

--if the entity is not in use we carry it with us (debugging)
function ENT:Think() 
	local ply = self.Entity:GetOwner() --get the player
	if (!SERVER && ply != LocalPlayer()) then return end
	
	if (ply:GetMoveType() != MOVETYPE_NOCLIP && false) then
		if (self.Entity.setup == 0) then
			self.Entity:InitRotation()
		else
			local NewAngles, NewOrigin, CorrecAng, PosAng = CalcRotation( ply )
			ply:SetLocalPos(Vector(0,0,0))
			ply:SetLocalAngles(Angle(0,0,0))
			self.Entity:RealSetAngles(PosAng)
			
		end
	else
		if (self.Entity.setup == 1) then
			self.Entity:FinRotation()
		end
		//Mimic the player
		self.Entity:SetPos(ply:RealGetPos())
		self.Entity:SetAngles(Angle(0,0,0))
	end

	phys = self.Entity:GetPhysicsObject()
	if IsValid(phys) then
		phys:AddAngleVelocity(-self.Entity:GetPhysicsObject():GetAngleVelocity())
		phys:SetVelocity(Vector(0,0,0))
	end

	if (!ply:Alive() && SERVER) then
		self:Remove()
	end
end 