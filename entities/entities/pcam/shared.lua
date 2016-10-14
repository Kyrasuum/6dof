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

	self.Entity:SetMoveType(MOVETYPE_CUSTOM)
	self.Entity:SetModel( "models/props_junk/sawblade001a.mdl" ) --the debugging model (not shown ordinarily)
	self.Entity:PhysicsInitBox(CrawlBoxMin, CrawlBoxMax) --give it the physical box that we decide on
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS ) -- we will decide how it moves too
	self.Entity:SetSolid( SOLID_VPHYSICS ) --it can be solid for a few seconds...
	self.Entity:DrawShadow(false) --don't draw the shadow - it will only say ERROR

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() --wake up the physics object so we can turn off collisions and gravity
		phys:EnableCollisions(true)
		phys:EnableGravity(false)
	else
		print("Error: NonValid PCam PhysObj")
	end
	
	//self.Entity:SetParent(self.Entity:GetOwner())
end

//Setup player parented to Pcam
function ENT:InitRotation()
	local ply = self.Entity:GetOwner() --get the player
	
	if SERVER then
		ply:SetMoveType(MOVETYPE_NONE)
		ply:SetLocalVelocity(Vector(0,0,0))
	end
	self.Entity:SetPos(ply:GetPos())
	--make the player move with us
	ply:SetParent(self.Entity) 
	ply:SetSolid( SOLID_VPHYSICS ) 

	if SERVER then
		self.Entity:StartMotionController()
		self.Entity:GetPhysicsObject():Wake()
	end
	self.Entity.setup = 1
end

//Finish parenting
function ENT:FinRotation()
	local ply = self.Entity:GetOwner() --get the player
	
	if SERVER then
		ply:SetScriptedVehicle(NULL)
		ply:SetClientsideVehicle(NULL)
		ply:SetMoveType(MOVETYPE_WALK)
	end
	ply:SetParent(NULL)
	ply:SetSolid( SOLID_VPHYSICS ) 
	
	if SERVER then
		self.Entity:StopMotionController()
	end
	self.Entity.setup = 0
end

--if the entity is not in use we carry it with us (debugging)
function ENT:Think() 
	local ply = self.Entity:GetOwner()
	if (ply != NULL) then
		if (GetConVar("planetview_view_enable"):GetInt() == 2 && self.Entity.setup == 0) then
			self.Entity:InitRotation()
		else
			if (self.Entity.setup == 1) then
				self.Entity:InitRotation()
			end
			self.Entity:SetPos(ply:GetPos())
		end
	end
	if (ply == NULL) then
		self:Remove()
	end
end 

--called very frequently - this is like a think() for the physics object
function ENT:PhysicsUpdate(phys)
	local ply = self.Entity:GetOwner()
	
	//Make newAngle rotate just like our view would
	self.Entity.newAngle = ply.view.angles
	self.Entity:SetAngles(self.Entity.newAngle)
end  

//To do: Add in a movement handler