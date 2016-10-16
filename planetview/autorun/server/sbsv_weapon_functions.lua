
local ents = {

	"crossbow_bolt",
	"npc_grenade_frag",
	"rpg_missile"

}

local function EntityTakeWeaponDamage( ent, inflictor, attacker, amount, dmginfo )

	local pClass 	= inflictor:GetClass()
	local pOwner 	= inflictor:GetOwner()

	if (!inflictor:IsValid()) then return end

	if (table.HasValue( ents, pClass )) then

		if (inflictor.m_iDamage) then

			dmginfo:SetDamage( inflictor.m_iDamage )

		end

		if (pOwner && pOwner:IsValid()) then

			dmginfo:SetAttacker( pOwner )

		end

	end

end

hook.Add( "EntityTakeDamage", "EntityTakeWeaponDamage", EntityTakeWeaponDamage )

