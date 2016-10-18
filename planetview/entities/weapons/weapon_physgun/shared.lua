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

function SWEP:Reload()

end

function SWEP:Think()

end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

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
        --[[-- Check if this car is already physgun
        if ent == v.ent then
            return false
        end]]

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
            local offset = pos - (ply:GetPos() + (ply:GetAngles() * Vector(0,0,-dist)))

            -- Store what is picked up
            addPickup({
                ply = ply,
                ent = ent,
                offset = offset,
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

-- Player is sending updated rotational data
function tryRotate( args, ply )
    local pickup = getPickup(ply)
    -- Check if the player has something picked up
    if IsValid(pickup) then
        -- Grab vars
        local ent = pickup.ent

        -- Check if what we want to move is still valid
        if ent and IsValid(ent) then
            -- Grab offsets
            local offset = pickup.offset
            local dist = pickup.dist

            -- Move Pickup
            ent:SetPos( ply:GetPos() + ( args.a * Vector(0,0,-dist) ) + offset )

            -- Grab the entities angles
            local entAngle = ( args.r and args.s and ent.realAngles ) or ent:GetAngles()

            -- Workout rotations
            local rx = -entAngle * Vector(0, 1, 0)
            local ry = -entAngle * Vector(-math.cos(args.a.yaw), 0, math.sin(args.a.yaw))

            local rotx = Angle.AngleAxis((args.x or 0), rx)
            local roty = Angle.AngleAxis((args.y or 0), ry)

            -- Workout the new angle
            local newAng = entAngle * rotx * roty
            ent.realAngles = entAngle * rotx * roty

            -- Should we snap?
            if args.r and args.s then
                newAng.pitch = snapToDegree(newAng.pitch)
                newAng.roll = snapToDegree(newAng.roll)
                newAng.yaw = snapToDegree(newAng.yaw)
            end

            -- Apply rotation
            ent:SetAngles(newAng)

            -- Check if we picked up a vehicle
            if ent:IsVehicle() then
                -- Stop it from falling
                ent:SetVelocity(Vector(0, 0, 0))
                ent:SetAngleVelocity(Vector(0, 0, 0))
            end
        end
    end
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
    -- If we have something grabbed
    if hGrabbed then
        -- Stop rotating
        if key == IN_USE then
            bRotating = false
        end
    end
end)

-- Send rotational info
hook.Add("Think", "PhysgunUpdate", function()
	if (SERVER) then return end
	local ply = LocalPlayer()
    -- Check if we have an object grabbed
    if hGrabbed then
        -- Check if we've stopped firing
        if !input.IsButtonDown( MOUSE_LEFT ) then
            -- Drop the item
            tryDrop( ply )
            return
        end

        -- Start to build data
        local data = {
            a = ply:GetAngles()
        }

        -- Check if there was any rotation
        if bRotating then
            data.r = true

            if vRot.x ~= 0 then
                data.x = vRot.x /25
            end
            if vRot.y ~= 0 then
                data.y = vRot.y /25
            end

            -- Left shift (constant is a little broken atm)
            if input.IsShiftDown() then
                data.s = true
            end
        end

        -- Send the update
        tryRotate( data )

        -- Reset rotations
        vRot = Vector(0, 0, 0)
    end
end)