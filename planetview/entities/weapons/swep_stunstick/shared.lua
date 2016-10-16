

// Variables that are used on both client and server
SWEP.Category 		= "PlanetView"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_stunstick.mdl"
SWEP.WorldModel		= "models/weapons/w_stunbaton.mdl"
SWEP.AnimPrefix		= "stunbaton"
SWEP.HoldType		= "melee"

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category			= "Half-Life 2"
SWEP.activate			= Sound( "Weapon_StunStick.Activate" )
SWEP.deactivate			= Sound( "Weapon_StunStick.Deactivate" )

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

STUNSTICK_RANGE				= 75.0
STUNSTICK_REFIRE			= 0.8
STUNSTICK_BEAM_MATERIAL		= "sprites/lgtning.vmt"
STUNSTICK_GLOW_MATERIAL		= "sprites/light_glow02_add"
STUNSTICK_GLOW_MATERIAL2	= "effects/blueflare1"
STUNSTICK_GLOW_MATERIAL_NOZ	= "sprites/light_glow02_add_noz"

SWEP.Primary.Sound			= Sound( "Weapon_StunStick.Melee_Miss" )
SWEP.Primary.Hit			= Sound( "Weapon_StunStick.Melee_Hit" )
SWEP.Primary.Range			= STUNSTICK_RANGE
SWEP.Primary.Damage			= 40.0
SWEP.Primary.DamageType		= DMG_CLUB
SWEP.Primary.Force			= 0.5
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= STUNSTICK_REFIRE
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "None"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
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


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer		= self.Owner;

	if ( !pPlayer ) then
		return;
	end

	// Make sure we can swing first
	if ( !self:CanPrimaryAttack() ) then return end

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * self.Primary.Range )
		trace.filter	= pPlayer

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		self.Weapon:EmitSound( self.Primary.Hit );

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

		self:Hit( traceHit, pPlayer );

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	self:Swing( traceHit, pPlayer );

	return

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
function SWEP:Reload()
	return false
end

//-----------------------------------------------------------------------------
// Purpose: Get the damage amount for the animation we're doing
// Input  : hitActivity - currently played activity
// Output : Damage amount
//-----------------------------------------------------------------------------
function SWEP:GetDamageForActivity( hitActivity )
	return self.Primary.Damage;
end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:ImpactEffect( traceHit )

//#ifndef CLIENT_DLL

	local	data = EffectData();

	data:SetNormal( traceHit.HitNormal );
	data:SetOrigin( traceHit.HitPos + ( traceHit.HitNormal * 4.0 ) );

	util.Effect( "StunstickImpact", data );

//#endif

end

/*---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------*/
function SWEP:Holster( wep )

	self:SetStunState( false );

	return true;

end

//-----------------------------------------------------------------------------
// Purpose: Sets the state of the stun stick
//-----------------------------------------------------------------------------
function SWEP:SetStunState( state )

	self.m_bActive = state;

	if ( self.m_bActive ) then
		//FIXME: START - Move to client-side

		local vecAttachment;
		local vecAttachmentAngles;

		vecAttachment = self.Weapon:GetAttachment( 1 ).Pos;
		vecAttachmentAngles = self.Weapon:GetAttachment( 1 ).Ang;
		local data = EffectData();
			data:SetOrigin( vecAttachment );
			data:SetMagnitude( 1 );
		util.Effect( "Sparks", data );

		//FIXME: END - Move to client-side

		self.Weapon:EmitSound( self.activate );
	else
		self.Weapon:EmitSound( self.deactivate );
	end

end

//-----------------------------------------------------------------------------
// Purpose:
// Output : Returns true on success, false on failure.
//-----------------------------------------------------------------------------
function SWEP:Deploy()

	self:SetStunState( true );
if ( CLIENT ) then
	//Tony; we need to just do this
	self:SetupAttachmentPoints();
end

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW );
	self:SetDeploySpeed( self.Weapon:SequenceDuration() );

	return true;

end

BEAM_ATTACH_CORE_NAME	= "sparkrear"

//-----------------------------------------------------------------------------
// Purpose: Sets up the attachment point lookup for the model
//-----------------------------------------------------------------------------
function SWEP:SetupAttachmentPoints()

	// Setup points for both types of views
	if ( LocalPlayer():GetActiveWeapon() == self.Weapon && GetViewEntity() == LocalPlayer() ) then
		local szBeamAttachNamesTop =
		{
			"spark1a","spark2a","spark3a","spark4a",
			"spark5a","spark6a","spark7a","spark8a",
			"spark9a",
		};

		local szBeamAttachNamesBottom =
		{
			"spark1b","spark2b","spark3b","spark4b",
			"spark5b","spark6b","spark7b","spark8b",
			"spark9b",
		};

		// Lookup and store all connections
		for i = 1, NUM_BEAM_ATTACHMENTS do
			self.m_BeamAttachments[i]        = {}
			self.m_BeamAttachments[i].IDs    = {}
			self.m_BeamAttachments[i].IDs[0] = self.Weapon:LookupAttachment( szBeamAttachNamesTop[i] );
			self.m_BeamAttachments[i].IDs[1] = self.Weapon:LookupAttachment( szBeamAttachNamesBottom[i] );
		end

		// Setup the center beam point
		self.m_BeamCenterAttachment = self.Weapon:LookupAttachment( BEAM_ATTACH_CORE_NAME );
	else
		// Setup the center beam point
		self.m_BeamCenterAttachment = 1;
	end

end

//-----------------------------------------------------------------------------
// Purpose:
// Output : Returns true on success, false on failure.
//-----------------------------------------------------------------------------
function SWEP:GetStunState()
	return self.m_bActive;
end

/*---------------------------------------------------------
   Name: SWEP:Hit( )
   Desc: A convenience function to trace impacts
---------------------------------------------------------*/
function SWEP:Hit( traceHit, pPlayer )

	local vecSrc = pPlayer:GetShootPos();

	if ( SERVER ) then
		pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -16, -16, -40 ), Vector( 16, 16, 16 ), self:GetDamageForActivity(), self.Primary.DamageType, self.Primary.Force, false );
	end

	self:ImpactEffect( traceHit );

end


/*---------------------------------------------------------
   Name: SWEP:Swing( )
   Desc: A convenience function to trace impacts
---------------------------------------------------------*/
function SWEP:Swing( traceHit, pPlayer )
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

