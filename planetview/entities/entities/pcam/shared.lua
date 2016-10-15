/*
This file handles the physics interactions of pcam
*/
--basic entity declarations
ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName		= "player camera"
ENT.Author			= "Oochitecht"
ENT.Contact			= "Steam.com"

--initialize (speaks for itself really)
function ENT:Initialize()
	--angle aligning default
	self.Entity.newAngle = Angle(0,0,0)
	self.Entity.setup = 0

	--the physics box (collisions, bounding)
	--for the invisible space crawling entity
	--a 2x2 cube centred at the origin
	local CrawlBoxMin = Vector(-1, -1, -1)
	local CrawlBoxMax = Vector(1, 1, 1)

	self.Entity:PhysicsInitBox(CrawlBoxMin, CrawlBoxMax) --give it the physical box that we decide on
	self.Entity:DrawShadow(false) --don't draw the shadow - it will only say ERROR

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() --wake up the physics object so we can turn off collisions and gravity
		phys:EnableCollisions(false)
		phys:EnableGravity(false)
	else
		print("Error: NonValid PCam PhysObj")
	end
end

//Setup player parented to Pcam
function ENT:InitRotation()
	local ply = self.Entity:GetOwner() --get the player
	if (!SERVER) then return end

	ply:SetMoveType(MOVETYPE_NONE)
	ply:SetLocalVelocity(Vector(0,0,0))
	self.Entity:StartMotionController()
	self.Entity:GetPhysicsObject():Wake()
	ply:SetParent(self.Entity) 
	
	self.Entity.setup = 1
end

//Finish parenting
function ENT:FinRotation()
	local ply = self.Entity:GetOwner() --get the player
	if (!SERVER) then return end

	ply:SetMoveType(MOVETYPE_WALK)
	self.Entity:StopMotionController()
	ply:SetParent(NULL)
	
	self.Entity.setup = 0
end

--if the entity is not in use we carry it with us (debugging)
function ENT:Think() 
	local ply = self.Entity:GetOwner() --get the player
	if (!SERVER && ply != LocalPlayer()) then return end
	
	if (GetConVar("planetview_view_enable"):GetInt() == 2) then
		if (self.Entity.setup == 0) then
			self.Entity:InitRotation()
		else
			//Make newAngle rotate just like our view would
			//phys:GetEntity().newAngle = ply.view.angles
			self.Entity.newAngle = self.Entity.newAngle + Angle(1,0,0)
			print(self.Entity.newAngle)
			self.Entity:SetAngles(self.Entity.newAngle)
			self.Entity:SetPos( Vector(0,0, 1030) )
		end
	else
		if (self.Entity.setup == 1) then
			self.Entity:InitRotation()
		end
		//Mimic the player
		self.Entity:SetPos(ply:GetPos() + Vector(0,0,30.5))
		self.Entity:SetAngles(Angle(0,0,0))
	end
	if (!ply:Alive() && SERVER) then
		self:Remove()
	end
end 