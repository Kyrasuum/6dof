SWEP.Base 					= "weapon_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.ViewModel				= "models/weapons/c_superphyscannon.mdl"
SWEP.WorldModel				= "models/weapons/w_superphyscannon.mdl"
SWEP.UseHands 				= true
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV 			= 50
SWEP.Weight 				= 42
SWEP.AutoSwitchTo 			= true
SWEP.AutoSwitchFrom 		= true
SWEP.HoldType				= "physgun"
SWEP.FiresUnderwater 		= true
	

-- physgun variables
SWEP.hGrabbed               = nil
SWEP.bRotating              = false
SWEP.physRange              = 1000
	
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""
SWEP.Primary.Automatic      = false
	
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.Automatic    = false

SWEP.PrintName				= "Physics Gun"
SWEP.Category 				= "PlanetView"
SWEP.Author					= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= ""
SWEP.Slot					= 1
SWEP.SlotPos				= 9

function SWEP:Initialize()
	ply = self:GetOwner()
    if !ply || !IsValid(ply) then return end
	self.VM = ply:GetViewModel()
	local attachmentIndex = self.VM:LookupAttachment("muzzle")
	if attachmentIndex == 0 then attachmentIndex = self.VM:LookupAttachment("1") end
	self.Attach = attachmentIndex
end

function SWEP:DrawWorldModel()
    self:DrawModel()
    ply = self:GetOwner()
    if !ply || !IsValid(ply) then return end
    if ply:KeyDown(IN_ATTACK) then
        render.SetMaterial(Material( "cable/redlaser" ) )
        local startpos = self.VM:GetAttachment(self.Attach).Pos
        local endpos = self:GetOwner():GetAimVector()
        endpos:Mul( self.physRange )
        endpos:Add( startpos )
        render.DrawBeam(startpos, endpos, 40, 0, 12.5, Color(255, 255, 255, 255))
    end
end

function SWEP:PostDrawViewModel( vm, wep, ply )
    if ply:KeyDown(IN_ATTACK) then
        render.SetMaterial(Material( "cable/redlaser" ) )
        local startpos = self.VM:GetAttachment(self.Attach).Pos
        local endpos = self:GetOwner():GetAimVector()
        endpos:Mul( self.physRange )
        endpos:Add( startpos )
        render.DrawBeam(startpos, endpos, 40, 0, 12.5, Color(255, 255, 255, 255))
    end
end

//Unfreezes a prop
function SWEP:Reload()
    local ply = self.Owner
    local ent = ply:GetEyeTrace().Entity

    if !IsValid(ent) then return end
    
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:GetPhysicsObject():EnableMotion( true )
end

//Allows us to move a prop
function SWEP:PrimaryAttack()
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    if ( !IsFirstTimePredicted() ) then return end
    local ply = self:GetOwner()
	if !ply || !IsValid(ply) then return end
    -- Make sure we haven't already grabbed something
    if self.hGrabbed == nil then
        -- Attempt to grab an entity
        ent = ply:GetEyeTrace().Entity
        if ( ent && IsValid(ent) && AllowedToPickup(self, ent) && canPickup(ply, ent) ) then
            -- Store what is picked up
            ent:GetPhysicsObject():EnableMotion( true )

            self.hGrabbed = {
                ent = ent,
                dist = ply:GetPos():Distance(ent:GetPos())
            }

            self:Pickup()
            self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
        end
    end
end

//Freezes a prop
function SWEP:SecondaryAttack()
    self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    local ply = self:GetOwner()
    if !ply || !IsValid(ply) then return end
    local hit = ply:GetEyeTrace().Entity

    if ( !IsValid(hit) || !IsValid(hit:GetPhysicsObject()) ) then return end
    if SERVER then
        ply:AddFrozenPhysicsObject(hit,hit:GetPhysicsObject())
        hit:GetPhysicsObject():EnableMotion( false )
        ent:SetMoveType( MOVETYPE_NONE )
    end
    self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );
end

function SWEP:Holster()
    self.Weapon:Drop()
    return true
end
    
function SWEP:OnDrop()
    self.Weapon:Drop()
end
    
function SWEP:OwnerChanged()
    self.Weapon:Drop()
end

function SWEP:Pickup()
    local trace = self.Owner:GetEyeTrace()

    self.TP = ents.Create("prop_physics")
    self.TP:SetPos(self.hGrabbed.ent:GetPhysicsObject():GetPos())
    self.TP:SetModel("models/props_junk/PopCan01a.mdl")
    self.TP:Spawn()
    self.TP:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self.TP:SetColor(Color(255,255,255,0))
    self.TP:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self.TP:GetPhysicsObject():SetMass(50000)
    self.TP:GetPhysicsObject():EnableMotion(false)
    
    local bone = math.Clamp(trace.PhysicsBone,0,1)
    self.Const = constraint.Weld(self.TP, self.hGrabbed.ent, 0, bone,0,1)
end

function SWEP:Drop()
    if !IsValid(self) then return end

    if self.TP then
        if !IsValid(self.TP) then return end
        self.TP:Remove()
        self.TP = nil
    end
    
    if self.Const then
    if !IsValid(self.Const) then return end
        self.Const:Remove()
        self.Const = nil
    end
    if self.hGrabbed then
        self.hGrabbed = nil
    end
end

-- This function determines if a player can pickup a given entity
function AllowedToPickup( wep, ent )
    local ply = wep:GetOwner()
    if ply:GetPos():Distance(ent:GetPos()) > wep.physRange then
        return false
    end
    if ent:IsPlayer() then
        if ply:IsAdmin() then
            return true
        end
    elseif ent:IsVehicle() then
        if ent:GetOwner() == ply then
            return true
        end 
    else
        if ent:GetOwner() == ply then
            return true
        end 
    end
    return false
end

-- Check if someone else is already grabbing this entity
function canPickup( ply, ent )
    -- Check if this is a vehicle
    if ent:IsVehicle() then
        -- Check if someone is inside it
        if ent:GetDriver() then
            return false
        end
    end
    return true
end

-- Rotating a prop
function snapToDegree( newAng )
    -- Settings
    local snap = math.pi/4

    return math.floor(newAng/snap + 0.5)*snap
end

-- Send rotational info
function SWEP:Think()
	local ply = self:GetOwner()
    if !ply || !IsValid(ply) then return end
    -- Check if we have an object grabbed and currently firing
    if self.hGrabbed!=nil then
        //Grabbed entity updating
        if IsValid(self.TP) then
            local ent = self.hGrabbed.ent
            local dist = self.hGrabbed.dist
            local phys = ent:GetPhysicsObject()

            local pos = ply:GetAimVector()
            pos:Mul(dist)
            pos:Add(ply:EyePos())

            local angVel = ent:GetPhysicsObject():GetAngleVelocity()
            angVel:Mul(-1)

            self.TP:SetPos(pos)
            phys:AddAngleVelocity(angVel)

            -- Check if there was any rotation
            if self.bRotating then
                -- Left shift
                if ply:KeyDown(IN_SPEED) then
                end
            end
        end

        //Handling key press
        if ply:KeyPressed(IN_USE) then
            self.bRotating = true
        end
        //Doesnt work
        if ply:KeyPressed(IN_WEAPON1) || ply:KeyPressed(IN_WEAPON2) then
            //self.hGrabbed.dist = self.hGrabbed.dist + ply:KeyPressed(IN_WEAPON1) - ply:KeyPressed(IN_WEAPON2)
        end  
        //Handling key release
        if ply:KeyReleased(IN_USE) then
            self.bRotating = false
        end
        if ply:KeyReleased(IN_ATTACK) then
            self:Drop()
            self.hGrabbed = nil
            self.bRotating = false
        end
    end
end