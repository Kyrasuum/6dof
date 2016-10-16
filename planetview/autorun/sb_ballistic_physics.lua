
local meta = FindMetaTable( "Entity" )
if (!meta) then return end
if (!meta.gFireBullets) then meta.gFireBullets = meta.FireBullets end

local FireBullets = meta.FireBullets

if ( !meta.FirePenetratingBullets ) then

	function meta:FirePenetratingBullets( attacker, trace, dmginfo )

		/*
		// Don't go through metal
		if ( trace.MatType == MAT_METAL	||
			 trace.MatType == MAT_SAND ) then return end
		*/

		local Penetration	= self.Penetration	|| 1

		// Direction (and length) that we are gonna penetrate
		local Dir			= trace.Normal * 16;

		if ( trace.MatType == MAT_ALIENFLESH	||
			 trace.MatType == MAT_DIRT			||
			 trace.MatType == MAT_FLESH			||
			 trace.MatType == MAT_WOOD ) then -- dirt == plaster, and wood should be easier to penetrate so increase the distance
			Dir = trace.Normal * ( 16 * Penetration );
		end

		if ( !attacker:IsValid() ) then return end
		if ( !dmginfo:IsBulletDamage() ) then return end

		local t				= {}
		t.start				= trace.HitPos + Dir
		t.endpos			= trace.HitPos
		t.filter			= self.Owner
		t.mask				= MASK_SHOT

		local tr			= util.TraceLine( t )

		// Bullet didn't penetrate.
		if ( tr.StartSolid			||
			 tr.Fraction	>= 1.0	||
			 trace.Fraction	<= 0.0 ) then return end

		// Fire bullet from the exit point using the original tradjectory
		local info		= {}
		info.Src		= tr.HitPos
		info.Attacker	= attacker
		info.Dir		= trace.Normal
		info.Spread		= vec3_origin
		info.Num		= 1
		info.Damage		= dmginfo:GetDamage()

		info.Callback = function( attacker, trace, dmginfo )
			return self:FirePenetratingBullets( attacker, trace, dmginfo )
		end;

		info.Tracer		= 0

		self:FireBullets( info )

		return {

			damage	= true,
			effects	= true

		}

	end

end

//-----------------------------------------------------------------------------
// Purpose: Make a tracer effect
//-----------------------------------------------------------------------------
function util.Tracer( vecStart, vecEnd, iEntIndex, iAttachment, flVelocity, pCustomTracerName )

	local data = EffectData();
	data:SetStart( vecStart );
	data:SetOrigin( vecEnd );
	data:SetEntity( ents.GetByIndex( iEntIndex ) );
	data:SetScale( flVelocity );
	data:SetRadius( 0.1 );

	if ( iAttachment ) then
		// Stomp the start, since it's not going to be used anyway
		data:SetAttachment( iAttachment );
	end

	// Fire it off
	if ( pCustomTracerName ) then
		util.Effect( pCustomTracerName, data );
	else
		util.Effect( "Tracer", data );
	end

end


//------------------------------------------------------------------------------
// Purpose : Creates both an decal and any associated impact effects (such
//			 as flecks) for the given iDamageType and the trace's end position
// Input   :
// Output  :
//------------------------------------------------------------------------------
function util.ImpactTrace( traceHit, pPlayer )

	if ( traceHit.MatType == MAT_GRATE ) then
		return;
	end

	local vecSrc		= traceHit.StartPos;
	local vecDirection	= traceHit.Normal;

	if ( pPlayer && pPlayer:IsPlayer() ) then
		vecSrc			= pPlayer:GetShootPos();
		vecDirection	= pPlayer:GetAimVector();
	else
		pPlayer			= GetWorldEntity()
	end

	local info			= {};
	info.Src			= vecSrc;
	info.Dir			= vecDirection;
	info.Num			= 1;
	info.Damage			= 0;
	info.Force			= 0;
	info.Tracer			= 0;
	info.Callback		= function( attacker, tr, dmginfo )
		return {
			damage		= false,
			effects		= true
		}
	end;

	return FireBullets( pPlayer, info );

end
