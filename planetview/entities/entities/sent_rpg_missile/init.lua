
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
//include( 'outputs.lua' )


//-----------------------------------------------------------------------------
// Purpose:
//
//
//-----------------------------------------------------------------------------
function ENT:Precache()

	util.PrecacheModel( "models/weapons/w_missile.mdl" );
	util.PrecacheModel( "models/weapons/w_missile_launch.mdl" );
	util.PrecacheModel( "models/weapons/w_missile_closed.mdl" );

end


//-----------------------------------------------------------------------------
// Purpose:
//
//
//-----------------------------------------------------------------------------
function ENT:Initialize()

	self:Precache();

	self.Entity:SetSolid( SOLID_BBOX );
	self.Entity:SetModel("models/weapons/w_missile_launch.mdl");
	self.Entity:SetCollisionBounds( -Vector(4,4,4), Vector(4,4,4) );

	self.Entity:SetMoveType( MOVETYPE_FLYGRAVITY );
	self.Entity:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE );
	self.Think = self.IgniteThink;

	self.Entity:NextThink( CurTime() + 0.3 );

	self.m_takedamage = DAMAGE_YES;
	self.m_iHealth = 100;
	self.m_iMaxHealth = 100;
	self.m_bloodColor = DONT_BLEED;
	self.m_flGracePeriodEndsAt = 0;

	self.Entity:AddFlag( FL_OBJECT );

end


//---------------------------------------------------------
//---------------------------------------------------------
function ENT:Event_Killed( info )

	self.m_takedamage = DAMAGE_NO;

	self:ShotDown();

end

function ENT:PhysicsSolidMaskForEntity()

	return self.BaseClass:PhysicsSolidMaskForEntity() || CONTENTS_HITBOX;

end

//---------------------------------------------------------
//---------------------------------------------------------
function ENT:OnTakeDamage( info )

	if ( ( info:GetDamageType() != (DMG_MISSILEDEFENSE || DMG_AIRBOAT) ) ) then
		return 0;
	end

	self.bIsDamaged = nil;
	if( self.m_iHealth <= self:AugerHealth() ) then
		// This missile is already damaged (i.e., already running AugerThink)
		self.bIsDamaged = true;
	else
		// This missile isn't damaged enough to wobble in flight yet
		self.bIsDamaged = false;
	end

	local nRetVal = self.BaseClass:OnTakeDamage( info );

	if( !self.bIsDamaged ) then
		if ( self.m_iHealth <= self:AugerHealth() ) then
			self:ShotDown();
		end
	end

	return nRetVal;

end


//-----------------------------------------------------------------------------
// Purpose: Stops any kind of tracking and shoots dumb
//-----------------------------------------------------------------------------
function ENT:DumbFire()

	self.Think = function( ... ) return end;
	self.Entity:SetMoveType( MOVETYPE_FLY );

	self.Entity:SetModel("models/weapons/w_missile.mdl");
	self.Entity:SetCollisionBounds( vec3_origin, vec3_origin );

	self.Entity:EmitSound( "Missile.Ignite" );

	// Smoke trail.
	self:CreateSmokeTrail();

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function ENT:SetGracePeriod( flGracePeriod )

	self.m_flGracePeriodEndsAt = CurTime() + flGracePeriod;

	// Go non-solid until the grace period ends
	self.Entity:AddSolidFlags( FSOLID_NOT_SOLID );

end

//---------------------------------------------------------
//---------------------------------------------------------
function ENT:AccelerateThink()

	local vecForward;

	// !!!UNDONE - make this work exactly the same as HL1 RPG, lest we have looping sound bugs again!
	self.Entity:EmitSound( "Missile.Accelerate" );

	self:AddEffects( EF_LIGHT );

	vecForward = AngleVectors( self.Entity:GetLocalAngles() );
	self.Entity:SetVelocity( vecForward * RPG_SPEED );

	self.Think = self.SeekThink;
	self.Entity:NextThink( CurTime() + 0.1 );

end

AUGER_YDEVIANCE = 20.0
AUGER_XDEVIANCEUP = 8.0
AUGER_XDEVIANCEDOWN = 1.0

//---------------------------------------------------------
//---------------------------------------------------------
function ENT:AugerThink()

	// If we've augered long enough, then just explode
	if ( self.m_flAugerTime < CurTime() ) then
		self:Explode();
		return;
	end

	if ( self.m_flMarkDeadTime < CurTime() ) then
		self.m_lifeState = LIFE_DYING;
	end

	local angles = self.Entity:GetLocalAngles();

	angles.y = angles.y + math.Rand( -AUGER_YDEVIANCE, AUGER_YDEVIANCE );
	angles.x = angles.x + math.Rand( -AUGER_XDEVIANCEDOWN, AUGER_XDEVIANCEUP );

	self.Entity:SetLocalAngles( angles );

	local vecForward;

	vecForward = AngleVectors( self.Entity:GetLocalAngles() );

	self.Entity:SetVelocity( vecForward * 1000.0 );

	self.Entity:NextThink( CurTime() + 0.05 );

end

//-----------------------------------------------------------------------------
// Purpose: Causes the missile to spiral to the ground and explode, due to damage
//-----------------------------------------------------------------------------
function ENT:ShotDown()

	local	data = EffectData();
	data:SetOrigin( self.Entity:GetPos() );

	util.Effect( "RPGShotDown", data );

	if ( self.m_hRocketTrail != NULL ) then
		self.m_hRocketTrail.m_bDamaged = true;
	end

	self.Think = self.AugerThink;
	self.Entity:NextThink( CurTime() );
	self.m_flAugerTime = CurTime() + 1.5;
	self.m_flMarkDeadTime = CurTime() + 0.75;

	// Let the RPG start reloading immediately
	if ( self.m_hOwner != NULL ) then
		self.m_hOwner:NotifyRocketDied();
		self.m_hOwner = NULL;
	end

end


//-----------------------------------------------------------------------------
// The actual explosion
//-----------------------------------------------------------------------------
function ENT:DoExplosion()

	// Explode
	ExplosionCreate( GetAbsOrigin(), GetAbsAngles(), GetOwnerEntity(), GetDamage(), GetDamage() * 2,
		SF_ENVEXPLOSION_NOSPARKS || SF_ENVEXPLOSION_NODLIGHTS || SF_ENVEXPLOSION_NOSMOKE, 0.0, this);

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function ENT:Explode()

	// Don't explode against the skybox. Just pretend that
	// the missile flies off into the distance.
	local forward;

	forward = self.Entity:GetForward();

	local tr = {};
	tr.start = self.Entity:GetPos();
	tr.endpos = self.Entity:GetPos() + forward * 16;
	tr.mask = MASK_SHOT;
	tr.filter = self;
	tr.collision = COLLISION_GROUP_NONE;
	tr = util.TraceLine( tr );

	self.m_takedamage = DAMAGE_NO;
	self.Entity:SetSolid( SOLID_NONE );
	if( tr.Fraction == 1.0 || !(tr.HitSky) ) then
		self:DoExplosion();
	end

	if( self.m_hRocketTrail ) then
		self.m_hRocketTrail:SetLifetime(0.1);
		self.m_hRocketTrail = NULL;
	end

	if ( self.m_hOwner != NULL ) then
		self.m_hOwner:NotifyRocketDied();
		self.m_hOwner = NULL;
	end

	self.Entity:StopSound( "Missile.Ignite" );
	self.Entity:Remove();

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pOther -
//-----------------------------------------------------------------------------
function ENT:Touch( pOther )

	// Don't touch triggers (but DO hit weapons)
	if ( pOther:GetCollisionGroup() != COLLISION_GROUP_WEAPON ) then
		return;
	end

	self:Explode();

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function ENT:CreateSmokeTrail()

	if ( self.m_hRocketTrail ) then
		return;
	end

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function ENT:IgniteThink()

	self.Entity:SetMoveType( MOVETYPE_FLY );
	self.Entity:SetModel("models/weapons/w_missile.mdl");
	self.Entity:SetCollisionBounds( vec3_origin, vec3_origin );
 	self.Entity:SetSolid( SOLID_NONE );

	//TODO: Play opening sound

	local vecForward;

	self.Entity:EmitSound( "Missile.Ignite" );

	vecForward = self.Entity:GetLocalAngles();
	self.Entity:SetVelocity( vecForward * RPG_SPEED );

	self.Think = self.SeekThink;
	self.Entity:NextThink( CurTime() );

	if ( self.m_hOwner && self.m_hOwner:GetOwner() ) then
		local pPlayer = self.m_hOwner:GetOwner();

		local white = Color( 255,225,205,64 );
		//UTIL_ScreenFade( pPlayer, white, 0.1f, 0.0f, FFADE_IN );
	end

	self:CreateSmokeTrail();

end


//-----------------------------------------------------------------------------
// Gets the shooting position
//-----------------------------------------------------------------------------
function ENT:GetShootPosition( pLaserDot, pShootPosition )

	if ( pLaserDot:GetOwner() != NULL ) then
		//FIXME: Do we care this isn't exactly the muzzle position?
		pShootPosition = pLaserDot:GetOwner():LocalToWorld( pLaserDot:GetOwner():OBBCenter() );
	else
		pShootPosition = pLaserDot:GetChasePosition();
	end

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
RPG_HOMING_SPEED	= 0.125

function ENT:ComputeActualDotPosition( pLaserDot, pActualDotPosition, pHomingSpeed )

	pHomingSpeed = RPG_HOMING_SPEED;
	if ( pLaserDot:GetTargetEntity() ) then
		pActualDotPosition = pLaserDot:GetChasePosition();
		return;
	end

	local vLaserStart;
	vLaserStart = self:GetShootPosition( pLaserDot );

	//Get the laser's vector
	local vLaserDir;
	vLaserDir = VectorSubtract( pLaserDot:GetChasePosition(), vLaserStart );

	//Find the length of the current laser
	local flLaserLength = VectorNormalize( vLaserDir );

	//Find the length from the missile to the laser's owner
	local flMissileLength = self.Entity:GetPos():Distance( vLaserStart );

	//Find the length from the missile to the laser's position
	local vecTargetToMissile;
	vecTargetToMissile = VectorSubtract( self.Entity:GetPos(), pLaserDot:GetChasePosition() );
	local flTargetLength = VectorNormalize( vecTargetToMissile );

	// See if we should chase the line segment nearest us
	if ( ( flMissileLength < flLaserLength ) || ( flTargetLength <= 512.0 ) ) then
		pActualDotPosition = UTIL_PointOnLineNearestPoint( vLaserStart, pLaserDot:GetChasePosition(), GetAbsOrigin() );
		pActualDotPosition = pActualDotPosition + ( vLaserDir * 256.0 );
	else
		// Otherwise chase the dot
		pActualDotPosition = pLaserDot:GetChasePosition();
	end

//	NDebugOverlay::Line( pLaserDot->GetChasePosition(), vLaserStart, 0, 255, 0, true, 0.05f );
//	NDebugOverlay::Line( GetAbsOrigin(), *pActualDotPosition, 255, 0, 0, true, 0.05f );
//	NDebugOverlay::Cross3D( *pActualDotPosition, -Vector(4,4,4), Vector(4,4,4), 255, 0, 0, true, 0.05f );

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function ENT:SeekThink()

	local	pBestDot	= NULL;
	local		flBestDist	= MAX_TRACE_LENGTH;
	local		dotDist;

	// If we have a grace period, go solid when it ends
	if ( self.m_flGracePeriodEndsAt ) then
		if ( self.m_flGracePeriodEndsAt < CurTime() ) then
			self.Entity:SetSolid( SOLID_NONE );
			self.m_flGracePeriodEndsAt = 0;
		end
	end

	//Search for all dots relevant to us
	for _, pEnt in pairs( self:GetLaserDotList() ) do
		if ( !pEnt:IsOn() ) then
			break;
		end

		if ( pEnt:GetOwner() != self.Entity:GetOwner() ) then
			break;
		end

		dotDist = (self.Entity:GetPos() - pEnt:GetPos()):Length();

		//Find closest
		if ( dotDist < flBestDist ) then
			pBestDot	= pEnt;
			flBestDist	= dotDist;
		end
	end

	//If we have a dot target
	if ( pBestDot == NULL ) then
		//Think as soon as possible
		self.Entity:NextThink( CurTime() );
		return;
	end

	local pLaserDot = pBestDot;
	local	targetPos;

	local flHomingSpeed;
	local vecLaserDotPosition;
	self:ComputeActualDotPosition( pLaserDot, targetPos, flHomingSpeed );

	if ( self:IsSimulatingOnAlternateTicks() ) then
		flHomingSpeed = flHomingSpeed * 2;
	end

	local	vTargetDir;
	vTargetDir = VectorSubtract( targetPos, self.Entity:GetPos() );
	local flDist = VectorNormalize( vTargetDir );

	local	vDir	= self.Entity:GetVelocity();
	local	flSpeed	= VectorNormalize( vDir );
	local	vNewVelocity = vDir;
	if ( FrameTime() > 0.0 ) then
		if ( flSpeed != 0 ) then
			vNewVelocity = ( flHomingSpeed * vTargetDir ) + ( ( 1 - flHomingSpeed ) * vDir );

			// This computation may happen to cancel itself out exactly. If so, slam to targetdir.
			if ( VectorNormalize( vNewVelocity ) < 1e-3 ) then
				if (flDist != 0) then
					vNewVelocity = vTargetDir;
				else
					vNewVelocity = vDir;
				end
			end
		else
			vNewVelocity = vTargetDir;
		end
	end

	local	finalAngles;
	finalAngles = VectorAngles( vNewVelocity );
	self.Entity:SetAngles( finalAngles );

	vNewVelocity = vNewVelocity * flSpeed;
	self.Entity:SetVelocity( vNewVelocity );

	if( self.Entity:GetVelocity() == vec3_origin ) then
		// Strange circumstances have brought this missile to halt. Just blow it up.
		self:Explode();
		return;
	end

	// Think as soon as possible
	self.Entity:NextThink( CurTime() );

end



