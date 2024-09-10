AddCSLuaFile()

local PLAYER = FindMetaTable("Player") --Get the meta table of player

function PLAYER:GetLocalVelocity()
	-- returns the players local velocity
	EyeAngles = self:GetAngles()
	EyeAngles.pitch = 0
	LocalVel = WorldToLocal( self:GetVelocity(), Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVel
end

function PLAYER:GetLocalPos()
	-- return the players local position
	EyeAngles = self:GetAngles()
	EyeAngles.pitch = 0
	LocalVel = WorldToLocal( self:GetPos(), Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVel
end

function PLAYER:GetWAngles()
	-- returns the players world angles
	if( self.WAngles == nil ) then self.WAngles = Angle(0,0,0) end
	if( self.Delay == nil ) then self.Delay = 0 end

	return self.WAngles
end

function PLAYER:SetWAngles( Wangle )
	-- sets the world angles for the player
	if( self.Delay == nil ) then self.Delay = 0 end
	if( CurTime() > self.Delay ) then
		self.Delay = CurTime() + 0.1
		if ( CLIENT ) then
			net.Start( "WangleReciver" )
				net.WriteAngle( Wangle )
			net.SendToServer()
		else
			net.Start( "WangleSender" )
				net.WriteEntity( self )
				net.WriteAngle( Wangle )
			net.Broadcast()
		end
	end

	self.WAngles = Wangle
end

function PLAYER:GetWDir()
	-- get the player world look direction
	if( self.WDir == nil ) then self.WDir = Vector(0,0,0) end
	return self.WDir
end

function PLAYER:SetWDir( NewWDir )
	-- sets the players world look direction
	self.WDir = NewWDir
end

function PLAYER:ToLocal(VectorFrom)
	-- converts a vector from world to local to player
	EyeAngles = self:GetAngles()
	EyeAngles.pitch = 0
	LocalVectorFrom = WorldToLocal( VectorFrom, Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVectorFrom
end

function PLAYER:GetLocalVelocityPitch()
	-- returns the players local velocity
	EyeAngles = self:GetAngles()
	LocalVel = WorldToLocal( self:GetVelocity(), Angle(0,0,0) , Vector(0,0,0), EyeAngles )
	return LocalVel
end