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
SWEP.Const                  = nil
SWEP.Const2                 = nil
	
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""
SWEP.Primary.Automatic      = true
	
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

//Unfreezes a prop
function SWEP:Reload()
    local ply = self.Owner
    local ent = ply:GetEyeTrace().Entity

    if !IsValid(ent) then return end
    
    local effectdata = EffectData()
    effectdata:SetOrigin( ent:GetPos() )
    effectdata:SetEntity( ent )
    util.Effect( "phys_unfreeze", effectdata )

    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:GetPhysicsObject():EnableMotion( true )
    return true
end

//Allows us to move a prop
function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    if !ply || !IsValid(ply) then return end

    local trace = self.Owner:GetEyeTrace()

    if !self.TP then
        self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
        self.Owner:SetAnimation( PLAYER_ATTACK1 )
        if !IsValid(self.TP) then
            local trace = util.TraceLine( {
                start = ply:EyePos(),
                endpos = ply:EyePos() + ply:EyeAngles():Forward() * self.physRange,
                filter = {}
            } )
            self.TP = ents.Create("prop_physics")
            self.TP:SetPos(trace.HitPos)
            self.TP:SetModel("models/props_junk/PopCan01a.mdl")
            self.TP:Spawn()
            self.TP:SetCollisionGroup(COLLISION_GROUP_WORLD)
            self.TP:SetColor(Color(255,255,255,0))
            self.TP:SetRenderMode(RENDERMODE_TRANSCOLOR)
            self.TP:GetPhysicsObject():SetMass(50000)
            self.TP:GetPhysicsObject():EnableMotion(false)
            
            self.Const2 = constraint.Rope(ply,self.TP, 0,0,Vector(0,0,0),
                Vector(0,0,0),1000,0,0,100,"cable/redlaser",true)
        end
    end
    -- Make sure we haven't already grabbed something
    if self.hGrabbed == nil then
        local trace = util.TraceLine( {
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * self.physRange,
            filter = {self.TP}
        } )
        //update TP
        self.TP:SetPos(trace.HitPos)

        -- Attempt to grab an entity
        ent = trace.Entity
        if ( ent && IsValid(ent) && AllowedToPickup(ply, ent) ) then
            -- Store what is picked up
            ent:GetPhysicsObject():EnableMotion( true )

            self.hGrabbed = {
                ent = ent,
                dist = ply:GetPos():Distance(ent:GetPos())
            }

            local bone = math.Clamp(trace.PhysicsBone,0,1)
            self.Const = constraint.Weld(self.TP,ent,0,bone,0,1)
        end
    else
        //Grabbed entity updating
        local ent = self.hGrabbed.ent
        local phys = ent:GetPhysicsObject()

        local angVel = ent:GetPhysicsObject():GetAngleVelocity()
        angVel:Mul(-1)
        phys:AddAngleVelocity(angVel)

        //update TP
        local dist = self.hGrabbed.dist

        local pos = ply:GetAimVector()
        pos:Mul(dist)
        pos:Add(ply:EyePos())

        self.TP:SetPos(pos)
    end
    self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )
    return true
end

hook.Add("CreateMove", "MouseControl", function(cmd)
    ply = LocalPlayer()
    wep = ply:GetActiveWeapon()

    if ply:KeyPressed(IN_USE) && wep.hGrabbed != nil then
        --update the cumualative output
        X = cmd:GetMouseX()/10
        Y = -cmd:GetMouseY()/10

        wep.bRotating = true
        wep.hGrabbed.dist = wep.hGrabbed.dist + cmd:GetForwardMove() + cmd:GetMouseWheel()
        -- Left shift
        if ply:KeyDown(IN_SPEED) then
            snapToDegree( Angle(0,0,0) )
        end

        --reset
        cmd:ClearMovement()
        cmd:RemoveKey(IN_FORWARD)
        cmd:RemoveKey(IN_BACK)
    end
        
end)

//Freezes a prop
function SWEP:SecondaryAttack()
    self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    local ply = self:GetOwner()
    if !ply || !IsValid(ply) then return end
    local hit = ply:GetEyeTrace().Entity

    if ( !IsValid(hit) || !IsValid(hit:GetPhysicsObject()) ) then return end
    if SERVER then
        hit:GetPhysicsObject():EnableMotion( false )
        hit:SetMoveType( MOVETYPE_NONE )
        local effectdata = EffectData()
        effectdata:SetOrigin( hit:GetPos() )
        effectdata:SetEntity( hit )
        util.Effect( "phys_freeze", effectdata )
    end
    self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );
    return true
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

function SWEP:Drop()
    if !IsValid(self) then return end

    if self.TP && IsValid(self.TP) then
        self.TP:Remove()
        self.TP = nil
    end
    if self.Const2 && IsValid(self.Const2) then
        self.Const2:Remove()
        self.Const2 = nil
    end
    if self.Const && IsValid(self.Const) then
        self.Const:Remove()
        self.Const = nil
    end
    if self.hGrabbed then
        self.hGrabbed = nil
    end
end

-- This function determines if a player can pickup a given entity
function AllowedToPickup( ply, ent )
    if ent:IsPlayer() && !ply:IsAdmin() then
        return false
    elseif ent:IsVehicle() then
        -- Check if someone is inside it
        if ent:GetDriver() then
            return false
        end 
    elseif ent:IsWorld() then
        return false
    end
    return true
end

-- Rotating a prop
function snapToDegree( newAng )
    -- Settings
    local snap = math.pi/4

    return math.floor(newAng/snap + 0.5)*snap
end

//Handling key releases
function SWEP:Think()
    local ply = self:GetOwner()
    if !ply || !IsValid(ply) then return end
    
    if ply:KeyReleased(IN_USE) then
        self.bRotating = false
    end
    if ply:KeyReleased(IN_ATTACK) then
        self:Drop()
        self.hGrabbed = nil
        self.bRotating = false
    end
end