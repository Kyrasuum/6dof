
HL2_WEAPONS = {

	"weapon_357",
	"weapon_ar2",
	// "weapon_bugbait",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_frag",
	"weapon_pistol",
	"weapon_rpg",
	"weapon_shotgun",
	"weapon_smg1",
	"weapon_stunstick"

}

local meta = FindMetaTable( "Weapon" )
if (!meta) then return end

local SetNextPrimaryFire = meta.SetNextPrimaryFire
local SetNextSecondaryFire = meta.SetNextSecondaryFire

// In this file we're adding functions to the weapon meta table.
// This means you'll be able to call functions here straight from the weapon object
// You can even override already existing functions.

function meta:SetNextPrimaryFire( timestamp )

	timestamp = timestamp - CurTime()
	timestamp = timestamp / GetConVarNumber( "phys_timescale" )
	SetNextPrimaryFire( self, CurTime() + timestamp )

end

function meta:SetNextSecondaryFire( timestamp )

	timestamp = timestamp - CurTime()
	timestamp = timestamp / GetConVarNumber( "phys_timescale" )
	SetNextSecondaryFire( self, CurTime() + timestamp )

end

