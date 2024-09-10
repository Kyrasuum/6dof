AddCSLuaFile()

local real_GetPlayerTrace = util.GetPlayerTrace
function util.GetPlayerTrace(ply, dir)
	-- override player trace to utilize new world angles and positions of player
    if not ply.WantRotate then
        return real_GetPlayerTrace(ply, dir)
    else
        local eyeTrace = real_GetPlayerTrace(ply)
        local plyEyePos = ply:GetPos() + (ply.newUpDir or Vector()) * 64
        local _, plyEyeAngles = LocalToWorld(Vector(), ply:EyeAngles(), Vector(), ply:GetWAngles())
        eyeTrace.endpos = plyEyePos + plyEyeAngles:Forward() * 32768
        eyeTrace.start = plyEyePos
        return eyeTrace
    end
end

local PLAYER = FindMetaTable("Player")
PLAYER.real_GetEyeTrace = PLAYER.GetEyeTrace
function PLAYER:GetEyeTrace()
	-- override player eye trace to utilize new world angles and positions of player
    if not self.WantRotate then
        return self:real_GetEyeTrace()
    else
        local plyEyePos = self:GetPos() + (self:GetWAngles():Up() or Vector()) * 64
        local _, plyEyeAngles = LocalToWorld(Vector(), self:EyeAngles(), Vector(), self:GetWAngles())
        return util.QuickTrace(plyEyePos, plyEyeAngles:Forward() * 32768, self)
    end
end

PLAYER.real_ShootPos = PLAYER.GetShootPos
PLAYER.real_GetAimVector = PLAYER.GetAimVector
PLAYER.real_SetEyeAngles = PLAYER.SetEyeAngles

local ENTITY = FindMetaTable("Entity")
PLAYER.real_EyePos = ENTITY.EyePos
PLAYER.real_EyeAngles = ENTITY.EyeAngles
PLAYER.real_GetPos = ENTITY.GetPos
function PLAYER:GetPos()
    local up = self:GetWAngles():Up()
    return self:real_GetPos() + Vector(0,0,15) - up*16 + up*self.Crouch
end

PLAYER.real_GetAngles = ENTITY.GetAngles
PLAYER.real_IsOnGround = ENTITY.IsOnGround
PLAYER.real_OnGround = ENTITY.OnGround
PLAYER.real_GetGroundEntity = ENTITY.GetGroundEntity
PLAYER.real_GetGroundSpeedVelocity = ENTITY.GetGroundSpeedVelocity
PLAYER.real_SetAngles = ENTITY.SetAngles
