

// Variables that are used on both client and server
SWEP.Category 		= "PlanetView"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_rpg.mdl"
SWEP.WorldModel		= "models/weapons/w_rocket_launcher.mdl"
SWEP.AnimPrefix		= "missile launcher"
SWEP.HoldType		= "rpg"

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category			= "Half-Life 2"
SWEP.m_bFiresUnderwater	= false
SWEP.m_bInitialStateUpdate= false;
SWEP.m_bHideGuiding = false;
SWEP.m_bGuiding = false;
SWEP.m_flSequenceDuration = CurTime();
SWEP.m_hLaserDot = NULL;
SWEP.m_hMissile = NULL;

SWEP.m_fMinRange1 = 40*12;
SWEP.m_fMinRange2 = 40*12;
SWEP.m_fMaxRange1 = 500*12;
SWEP.m_fMaxRange2 = 500*12;

RPG_BEAM_SPRITE		= "effects/laser1.vmt"
RPG_BEAM_SPRITE_NOZ	= "effects/laser1_noz.vmt"
RPG_LASER_SPRITE	= "sprites/redglow1.vmt"

RPG_MUZZLE_ATTACHMENT		= 1
RPG_GUIDE_ATTACHMENT		= 2
RPG_GUIDE_TARGET_ATTACHMENT	= 3

RPG_GUIDE_ATTACHMENT_3RD		= 4
RPG_GUIDE_TARGET_ATTACHMENT_3RD	= 5

RPG_LASER_BEAM_LENGTH	= 128

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Reload			= Sound( "common/null.wav" )
SWEP.Primary.Sound			= Sound( "Weapon_RPG.Single" )
SWEP.Primary.SoundNPC		= Sound( "Weapon_RPG.NPC_Single" )
SWEP.Primary.Empty			= Sound( "Weapon_SMG1.Empty" )
SWEP.Primary.Damage			= 150
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= 0.75
SWEP.Primary.DefaultClip	= 3					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "rpg_round"
SWEP.Primary.AmmoType		= "rpg_missile"

SWEP.Secondary.Special1		= Sound( "Weapon_RPG.LaserOn" )
SWEP.Secondary.Special2		= Sound( "Weapon_RPG.LaserOff" )
SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"

/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 0 )
		self:SetNPCMaxBurst( 0 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

	self:SetWeaponHoldType( self.HoldType )

end


function SWEP:SetupDataTables()

	self:DTVar( "Entity", 0, "Missile" );

end


/*---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()

	self.BaseClass:Precache();

	util.PrecacheSound( "Missile.Ignite" );
	util.PrecacheSound( "Missile.Accelerate" );

	// Laser dot...
	util.PrecacheModel( "sprites/redglow1.vmt" );
	util.PrecacheModel( RPG_LASER_SPRITE );
	util.PrecacheModel( RPG_BEAM_SPRITE );
	util.PrecacheModel( RPG_BEAM_SPRITE_NOZ );

end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if (!pPlayer) then
		return;
	end

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	if (self.m_bNeedReload) then
		return;
	end

	if ( self:Ammo1() <= 0 ) then
		self.Weapon:EmitSound( self.Primary.Empty );
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );

		return
	end

	if ( self.m_bIsUnderwater && !self.m_bFiresUnderwater ) then
		self.Weapon:EmitSound( self.Primary.Empty );
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );

		return;
	end

	// Can't have an active missile out
	if ( VERSION >= 72 ) then
		if ( self.dt.Missile != NULL ) then
			return;
		end
	elseif ( self.Weapon:GetNetworkedEntity( "Missile" ) != NULL ) then
		return;
	end

	// Can't be reloading
	if ( self.Weapon:GetActivity() == ACT_VM_RELOAD || self.m_bInReload ) then
		return;
	end

	local vecOrigin;
	local vecForward;

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 );

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local	vForward, vRight, vUp;

	vForward = pOwner:GetForward();
	vRight = pOwner:GetRight();
	vUp = pOwner:GetUp();

	local	muzzlePoint = pOwner:GetShootPos() + vForward * 12.0 + vRight * 6.0 + vUp * -3.0;

if ( !CLIENT ) then
	local vecAngles;
	vecAngles = pOwner:GetAimVector():Angle();

	local pMissile = ents.Create( self.Primary.AmmoType );
	pMissile:SetPos( muzzlePoint );
	pMissile:SetAngles( vecAngles );
	pMissile:SetOwner( self.Owner );
	pMissile:Spawn();

	// If the shot is clear to the player, give the missile a grace period
	local	tr;
	local vecEye = pOwner:EyePos();
	tr = {}
	tr.start = vecEye
	tr.endpos = vecEye + vForward * 128
	tr.mask = MASK_SHOT
	tr.filter = self.Weapon
	tr.collision = COLLISION_GROUP_NONE
	tr = util.TraceLine( tr );
	if ( tr.Fraction == 1.0 ) then
		pMissile.GracePeriod = 0.3;
	end

	pMissile.Damage = self.Primary.Damage;

	if ( VERSION >= 72 ) then
		self.dt.Missile = pMissile
	else
		self.Weapon:SetNetworkedEntity( "Missile", pMissile );
	end
	self.m_hMissile = pMissile;
end

	self:DecrementAmmo( self.Owner );
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	if ( !self.Owner:IsNPC() ) then
		self.Weapon:EmitSound( self.Primary.Sound );
	else
		self.Weapon:EmitSound( self.Primary.SoundNPC );
	end

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.m_bNeedReload = true;

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pOwner -
//-----------------------------------------------------------------------------
function SWEP:DecrementAmmo( pOwner )

	// Take away our primary ammo type
	pOwner:RemoveAmmo( self.Primary.NumAmmo, self.Primary.Ammo );

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : state -
//-----------------------------------------------------------------------------
function SWEP:SuppressGuiding( state )

	self.m_bHideGuiding = state;

if ( !CLIENT ) then

	if ( self.m_hLaserDot == NULL ) then
		self:StartGuiding();

		//STILL!?
		if ( self.m_hLaserDot == NULL ) then
			 return;
		end
	end

end

end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload( m_bInReload )

	if (!m_bInReload) then
		return;
	end

	self.m_bInReload = true;

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return false;
	end

	if ( pOwner:GetAmmoCount(self.Primary.Ammo) <= 0 ) then
		return false;
	end

	self.Weapon:EmitSound( self.Primary.Reload );

	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD );
	self.m_flSequenceDuration = CurTime() + self.Weapon:SequenceDuration();

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );

	return true;

end


/*---------------------------------------------------------
   Name: SWEP:PreThink( )
   Desc: Called before every frame
---------------------------------------------------------*/
function SWEP:PreThink()
end


/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	self:PreThink();

	if ( pPlayer:WaterLevel() >= 3 ) then
		self.m_bIsUnderwater = true;
	else
		self.m_bIsUnderwater = false;
	end

	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	//If we're pulling the weapon out for the first time, wait to draw the laser
	if ( ( self.m_bInitialStateUpdate ) && ( self.Weapon:GetActivity() != ACT_VM_DRAW ) ) then
		self:StartGuiding();
		self.m_bInitialStateUpdate = false;
	end

	// Supress our guiding effects if we're lowered
	if ( self.Weapon:GetActivity() == ACT_VM_IDLE_LOWERED ) then
		self:SuppressGuiding();
	else
		self:SuppressGuiding( false );
	end

	//Move the laser
	self:UpdateLaserPosition();

	if ( pPlayer:GetAmmoCount(self.Primary.Ammo) <= 0 && self.m_hMissile == NULL ) then
		self:StopGuiding();
	end

	if ( self.m_bInReload && self.m_flSequenceDuration <= CurTime() ) then
		self.m_bInReload			= false;
		self.m_bNeedReload			= false;
		self.m_flSequenceDuration	= CurTime();
	end

	if ( !self.m_bInitialStateUpdate && self.m_bNeedReload ) then
		if ( !self.m_hMissile || !self.m_hMissile:IsValid() ) then
			self:NotifyRocketDied()
		end
	end

end

//-----------------------------------------------------------------------------
// Purpose:
// Output : Vector
//-----------------------------------------------------------------------------
function SWEP:GetLaserPosition()

if ( !CLIENT ) then
	self:CreateLaserPointer();

	if ( self.m_hLaserDot != NULL ) then
		return self.m_hLaserDot:GetPos();
	end

	//FIXME: The laser dot sprite is not active, this code should not be allowed!
	assert(0);
end
	return vec3_origin;

end

//-----------------------------------------------------------------------------
// Purpose: NPC RPG users cheat and directly set the laser pointer's origin
// Input  : &vecTarget -
//-----------------------------------------------------------------------------
function SWEP:UpdateNPCLaserPosition( vecTarget )

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:SetNPCLaserPosition( vecTarget )
end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:GetNPCLaserPosition()

	return vec3_origin;

end

//-----------------------------------------------------------------------------
// Purpose:
// Output : Returns true if the rocket is being guided, false if it's dumb
//-----------------------------------------------------------------------------
function SWEP:IsGuiding()

	return self.m_bGuiding;

end

/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.m_bInitialStateUpdate = true;

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	// Restore the laser pointer after transition
	if ( self.m_bGuiding ) then
		local pOwner = self.Owner;

		if ( pOwner == NULL ) then
			return;
		end

		if ( pOwner:GetActiveWeapon() == self.Weapon ) then
			self:StartGuiding();
		end
	end

	return true

end

/*---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------*/
function SWEP:Holster( wep )

	//Can't have an active missile out
	if ( self.Weapon && self.Weapon:IsValid() ) then
		if ( VERSION >= 72 ) then
			if ( self.dt.Missile != NULL ) then
				if ( !CLIENT ) then
					self.Owner:DrawViewModel( true );
				end
				return false;
			end
		elseif ( self.Weapon:GetNetworkedEntity( "Missile" ) != NULL ) then
			if ( !CLIENT ) then
				self.Owner:DrawViewModel( true );
			end
			return false;
		end
	end

	self:StopGuiding();

	return self.BaseClass:Holster( wep )

end

//-----------------------------------------------------------------------------
// Purpose: Turn on the guiding laser
//-----------------------------------------------------------------------------
function SWEP:StartGuiding()

	// Don't start back up if we're overriding this
	if ( self.m_bHideGuiding ) then
		return;
	end

	self.m_bGuiding = true;

if ( !CLIENT ) then
	self.Weapon:EmitSound(self.Secondary.Special1);

	self:CreateLaserPointer();
end

end

//-----------------------------------------------------------------------------
// Purpose: Turn off the guiding laser
//-----------------------------------------------------------------------------
function SWEP:StopGuiding()

	self.m_bGuiding = false;

if ( !CLIENT ) then

	if ( self.Weapon && self.Weapon:IsValid() ) then
		self.Weapon:EmitSound( self.Secondary.Special2 );
	end

	// Kill the dot completely
	if ( self.m_hLaserDot != NULL ) then
		self.m_hLaserDot:Remove();
		self.m_hLaserDot = NULL;
	end
else
	if ( self.m_pBeam ) then
		//Tell it to die right away and let the beam code free it.
		self.m_pBeam.brightness = 0.0;
		self.m_pBeam.flags = self.m_pBeam.flags + !FBEAM_FOREVER;
		self.m_pBeam.die = CurTime() - 0.1;
		self.m_pBeam = NULL;
	end
end

end

//-----------------------------------------------------------------------------
// Purpose: Toggle the guiding laser
//-----------------------------------------------------------------------------
function SWEP:ToggleGuiding()

	if ( self:IsGuiding() ) then
		self:StopGuiding();
	else
		self:StartGuiding();
	end

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:UpdateLaserPosition( vecMuzzlePos, vecEndPos )

if ( !CLIENT ) then
	if ( vecMuzzlePos == nil || vecEndPos == nil ) then
		local pPlayer = self.Owner
		if ( !pPlayer ) then
			return
		end
		MAX_TRACE_LENGTH = 1000
		vecMuzzlePos = pPlayer:GetShootPos()
		forward = pPlayer:GetAimVector():Mul(MAX_TRACE_LENGTH)
		vecEndPos = vecMuzzlePos
		if (IsValid(forward)) then 
			vecEndPos = vecMuzzlePos:Add( forward )
		end
	end

	//Move the laser dot, if active
	local	tr;

	// Trace out for the endpoint
	tr = {}
	tr.start = vecMuzzlePos
	tr.endpos = vecEndPos
	tr.mask = MASK_SHOT
	tr.filter = self.Owner
	tr.collision = COLLISION_GROUP_NONE
	tr = util.TraceLine( tr );

	// Move the laser sprite
	if ( self.m_hLaserDot != NULL ) then
		local	laserPos = tr.HitPos;
		self.m_hLaserDot:SetPos( laserPos );
		self.m_hLaserDot:SetAngles( self.Owner:GetAimVector() + ( tr.HitNormal * 1.0 ) );

		if ( tr.Entity ) then
			local pHit = tr.Entity;

			if ( ( pHit != NULL ) && ( pHit.m_takedamage ) ) then
				self.m_hLaserDot:SetTargetEntity( pHit );
			end
		else
			self.m_hLaserDot:SetTargetEntity( NULL );
		end
	end
end

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:CreateLaserPointer()

if ( !CLIENT ) then
	if ( self.m_hLaserDot != NULL ) then
		return;
	end

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( pOwner:GetAmmoCount(self.Primary.Ammo) <= 0 ) then
		return;
	end

	self.m_hLaserDot = ents.Create( "env_laserdot" );
	self.m_hLaserDot:SetPos( self.Weapon:GetPos() );
	self.m_hLaserDot:SetOwner( self.Owner );
	// BUGBUG: Setting a model for the env_laserdot makes it visible for some reason.
	self.m_hLaserDot:SetModel( "models/error.mdl" );
	self.m_hLaserDot:Spawn();

	self:UpdateLaserPosition();
end

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:NotifyRocketDied()

	if ( VERSION >= 72 ) then
		self.dt.Missile = NULL;
	else
		self.Weapon:SetNetworkedEntity( "Missile", NULL );
	end
	self.m_hMissile = NULL;

	if ( self.Weapon:GetActivity() == ACT_VM_RELOAD || self.m_bInReload ) then
		return;
	end

	self:Reload( true );

end

//-----------------------------------------------------------------------------
// Purpose: Returns the attachment point on either the world or viewmodel
//			This should really be worked into the CBaseCombatWeapon class!
//-----------------------------------------------------------------------------
function SWEP:GetWeaponAttachment( attachmentId, outVector, dir /*= NULL*/ )

	local	angles;

	//Tony; third person attachment
	if ( self.Owner:GetActiveWeapon() == self.Weapon && GetViewEntity() == self.Owner) then
		local pOwner = self.Owner;

		if ( pOwner != NULL ) then
			pOwner:GetViewModel():GetAttachment( attachmentId );
		end
	else
		// We offset the IDs to make them correct for our world model
		self.Weapon:GetAttachment( attachmentId );
	end

	// Supply the direction, if requested
	if ( dir != NULL ) then
		angles = dir:Angle();
	end

end

/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
	return true
end


/*---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()
	return false
end


/*---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
---------------------------------------------------------*/
function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed / GetConVarNumber( "phys_timescale" ) )

	self.Weapon:SetNextPrimaryFire( CurTime() + speed )
	self.Weapon:SetNextSecondaryFire( CurTime() + speed )

end

