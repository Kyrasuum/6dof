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
	

-- variables that need global plugin scope
hGrabbed = nil
bRotating = false
vRot = Vector(0, 0, 0)
	
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""
	
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= ""

SWEP.PrintName				= "Physics Gun"
SWEP.Category 				= "PlanetView"
SWEP.Author					= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= ""
SWEP.Slot					= 1
SWEP.SlotPos				= 9

SWEP.left                   = false

function SWEP:Initialize()
	if SERVER then return end
	ply = LocalPlayer()
	self.VM = ply:GetViewModel()
	local attachmentIndex = self.VM:LookupAttachment("muzzle")
	if attachmentIndex == 0 then attachmentIndex = self.VM:LookupAttachment("1") end
	self.Attach = attachmentIndex
end

function SWEP:PostDrawViewModel()
    if (!self.left) then return end
	ply = LocalPlayer()
	render.SetMaterial(Material( "cable/redlaser" ) )
	local startpos = self.VM:GetAttachment(self.Attach).Pos
	local endpos = ply:GetAimVector()
	endpos:Mul( 1000 )
	endpos:Add( startpos )
	render.DrawBeam(startpos, endpos, 40, 0, 12.5, Color(255, 255, 255, 255))
    //self.lazer = false
end

//Unfreezes a prop
function SWEP:Reload()
    local ply = self.Owner
    local ent = ply:GetEyeTrace().Entity

    if !IsValid(ent) then return end
    
    if SERVER then
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ply:PhysgunUnfreeze()
    end
end

//Allows us to move a prop
function SWEP:PrimaryAttack()
    self.left = true
	pickupEntity( self.Owner )
end

//Freezes a prop
function SWEP:SecondaryAttack()
    local ply = self.Owner
    local hit = ply:GetEyeTrace().Entity

    if ( !IsValid(hit) || !IsValid(hit:GetPhysicsObject()) ) then return end
    
    if SERVER then
        ply:AddFrozenPhysicsObject(hit, hit:GetPhysicsObject())
        hit:SetMoveType(MOVETYPE_NONE)
    end
end

-- This function determines if a player can pickup a given entity
function AllowedToPickup( ply, ent )
    if ent:IsPlayer() then
        -- Must be a player
        if ply:IsAdmin() then
            return true
        end
    elseif ent:IsVehicle() then
        -- Must be a vehicle
        if ent:GetOwner() == ply then
            return true
        end 
    else
        -- Must be a static object
        if ent:GetOwner() == ply then
            return true
        end 
    end
    return false
end

-- Table of what is picked up
local oPickedUp = {}

function canPickup( ply, ent )
    -- Check if this is a vehicle
    if ent:IsVehicle() then
        -- Check if someone is inside it
        if ent:GetDriver() then
            return false
        end
    end

    for k, v in pairs(oPickedUp) do
        -- Check if this player already picked up something
        if ply == v.ply then
            return false
        end
    end

    return true
end

-- Makes a player pickup an object
function addPickup( pickup )
    table.insert(oPickedUp, pickup)
end

-- Returns what a player has picked up
function getPickup( ply )
    for k, v in pairs(oPickedUp) do
        -- Check if this player already picked up something
        if ply == v.ply then
            return v
        end
    end
end

-- Makes a player drop a given pickup
function removePickup( ply )
    for k, v in pairs(oPickedUp) do
        -- Check if this player already picked up something
        if ply == v.ply then
            -- Remove this pickup
            table.remove(oPickedUp, k)
        end
    end
end

-- A player wants to pick something up
function tryPickUp( ply, ent )
    if ent and IsValid(ent) and AllowedToPickup(ply, ent) then
        -- Check if someone else is already grabbing this entity
        if canPickup(ply, ent) then
            local pos = ent:GetPos()
            local ang = ent:GetAngles()
            local dist = ply:GetPos():Distance(pos)

            -- Store what is picked up
            addPickup({
                ply = ply,
                ent = ent,
                dist = dist
            })
            return
        end
    end
end

function snapToDegree( newAng )
    -- Settings
    local snap = math.pi/4

    return math.floor(newAng/snap + 0.5)*snap
end


-- Player has dropped their pickup
function tryDrop( ply )
	hGrabbed = nil
    bRotating = false
    -- Remove any pickups from this player
    removePickup(ply)
end

-- Player is scrolling
function tryScroll( ply )
    -- Check if this player has a pickup
    local pickup = getPickup(ply)
    if pickup then
        pickup.dist = pickup.dist + input.IsButtonDown( MOUSE_WHEEL_UP ) 
        						- input.IsButtonDown( MOUSE_WHEEL_DOWN )
    end
end

function pickupEntity( ply )
    -- Make sure we haven't already grabbed something
    if not hGrabbed then
        local oTrace = ply:GetEyeTrace()

        -- Attempt to grab an entity
        local ent = oTrace.Entity
        if ent then
            -- Store this as our grabbed entity
            hGrabbed = ent
            bRotating = false

            -- Tell the server
            tryPickUp( ply, ent )

            return
        end
    end
end


-- Hook key pressed
hook.Add("KeyPress", "PhysgunKeyDown", function( ply, key)
    if SERVER then return end
    if hGrabbed then
        -- Rotation
        if key == IN_USE then
            -- Start rotating
            bRotating = true
        end
        if input.IsButtonDown( MOUSE_WHEEL_UP ) || input.IsButtonDown( MOUSE_WHEEL_DOWN ) then
        	tryScroll( ply )
        end  
    end
end)

hook.Add("KeyRelease", "PhysunKeyUp", function( ply, key)
    if SERVER then return end
    -- If we have something grabbed
    if hGrabbed then
        -- Stop rotating
        if key == IN_USE then
            bRotating = false
        end
    end
end)

-- Send rotational info
function SWEP:Think()
	local ply = self.Owner
    -- Check if we have an object grabbed and currently firing
    if hGrabbed && self.left then
        -- Check if we've stopped firing
        if !input.IsButtonDown( MOUSE_LEFT ) then
            -- Drop the item
            self.left = false
            tryDrop( ply )
            return
        end

        -- Check if there was any rotation
        if bRotating then
            -- Left shift
            if input.IsShiftDown() then
            end
        end
    end
end