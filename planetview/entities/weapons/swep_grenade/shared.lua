

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "Grenade"
	SWEP.Author				= ""
	SWEP.IconLetter			= "4"

	killicon.AddFont( "sent_grenade_frag", "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.HoldType			= "grenade"
SWEP.Base				= "swep_frag"
SWEP.Category 			= "PlanetView"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.AmmoType		= "sent_grenade_frag"

function SWEP:PreThink()
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end
