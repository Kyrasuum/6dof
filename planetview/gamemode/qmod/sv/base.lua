function dpdeath( pl, killer, dmginfo )
	if killer:IsValid() && killer:IsPlayer() then
		if killer != pl then
			killer:SetNWInt( "Kills", killer:GetNWInt( "Kills" ) + 1 )
		end
	end
end
hook.Add( "DoPlayerDeath", "dpdeath", dpdeath )

local ply = FindMetaTable("Player");

function PlayerFootstep( ply, pos, foot, sound, volume, rf )
	if tobool(ply:GetInfoNum("jc_cfg_alf", 0)) then
		ply:EmitSound( "NPC_Antlion.Footstep", 30, 130 )
		return true
	else
		return false
	end
end
hook.Add( "PlayerFootstep", "Stepsound", PlayerFootstep )

function OnPlayerHitGround( ply )
	if tobool(ply:GetInfoNum("jc_cfg_xpl", 0)) then
		ent = ents.Create( "env_explosion" )
		if (ply:GetVelocity():Length() / 25.2) >= 88 then
			ent:SetPos( ply:GetPos( ) )
			ent:Fire( "explode", "", 0 )
			ent:Spawn( )
		end
	else
		--
	end
end
hook.Add( "OnPlayerHitGround", "boom", OnPlayerHitGround )