AddCSLuaFile()

local meta = FindMetaTable("Player") --Get the meta table of player

function meta:InAtmosphere()
	ent, range = FindNearestEntity( "planetphys", self, 65535 )
    if range > ent:GetTable().atmos then
		src:SetDSP(31) -- Space effect
    	return false
    else
		src:SetDSP(1) -- Normal effect
    	return true
    end
end

function meta:GetLocalVelocity()
	-- returns the players local velocity
	EyeAngles = self:GetAngles()
	EyeAngles.pitch = 0
	LocalVel = WorldToLocal( self:GetVelocity(), Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVel
end


function meta:GetLocalPos()
	-- return the players local position
	EyeAngles = self:GetAngles()
	EyeAngles.pitch = 0
	LocalVel = WorldToLocal( self:GetPos(), Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVel
end

function meta:GetWAngles()
	-- returns the players world angles
	if( self.WAngles == nil ) then self.WAngles = Angle(0,0,0) end
	if( self.Delay == nil ) then self.Delay = 0 end

	return self.WAngles
end

function meta:SetWAngles( Wangle )
	-- sets the world angles for the player
	if( self.Delay == nil ) then self.Delay = 0 end
	if( CLIENT and CurTime() > self.Delay ) then
		self.Delay = CurTime() + 0.1
		net.Start( "WangleReciver" )
			net.WriteAngle( Wangle )
		net.SendToServer()
	end

	self.WAngles = Wangle
end


function meta:GetWDir()
	-- get the player world look direction
	if( self.WDir == nil ) then self.WDir = Vector(0,0,0) end
	return self.WDir
end

function meta:SetWDir( NewWDir )
	-- sets the players world look direction
	self.WDir = NewWDir
end

function meta:ToLocal(VectorFrom)
	-- converts a vector from world to local to player
	EyeAngles = self:GetAngles()
	EyeAngles.pitch = 0
	LocalVectorFrom = WorldToLocal( VectorFrom, Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVectorFrom
end

function meta:GetLocalVelocityPitch()
	-- returns the players local velocity
	EyeAngles = self:GetAngles()
	LocalVel = WorldToLocal( self:GetVelocity(), Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVel
end
 
