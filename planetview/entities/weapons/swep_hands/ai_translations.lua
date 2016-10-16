
/*---------------------------------------------------------
   Name: SetupWeaponHoldTypeForAI
   Desc: Mainly a Todo.. In a seperate file to clean up the init.lua
---------------------------------------------------------*/
function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	self.ActivityTranslateAI [ ACT_STAND ] 						= ACT_STAND
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY

	self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN
	self.ActivityTranslateAI [ ACT_MP_CROUCHWALK ] 				= ACT_HL2MP_WALK_CROUCH

	self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ] 				= ACT_MELEE_ATTACK1

	self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD

end

