
ENT.Sound				= {}
ENT.Sound.Explode		= "BaseGrenade.Explode"

// Nice helper function, this does all the work.

/*---------------------------------------------------------
   Name: DoExplodeEffect
---------------------------------------------------------*/
function ENT:DoExplodeEffect()

	local info = EffectData();
	info:SetEntity( self.Entity );
	info:SetOrigin( self.Entity:GetPos() );

	util.Effect( "Explosion", info );

end

/*---------------------------------------------------------
   Name: OnExplode
   Desc: The grenade has just exploded.
---------------------------------------------------------*/
function ENT:OnExplode( pTrace )

	if ((pTrace.Entity != GetWorldEntity()) || (pTrace.HitBox != 0)) then
		// non-world needs smaller decals
		if( pTrace.Entity && !pTrace.Entity:IsNPC() ) then
			util.Decal( "SmallScorch", pTrace.HitPos + pTrace.HitNormal, pTrace.HitPos - pTrace.HitNormal );
		end
	else
		util.Decal( "Scorch", pTrace.HitPos + pTrace.HitNormal, pTrace.HitPos - pTrace.HitNormal );
	end

end

/*---------------------------------------------------------
   Name: OnInitialize
---------------------------------------------------------*/
function ENT:OnInitialize()
end

/*---------------------------------------------------------
   Name: StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end

/*---------------------------------------------------------
   Name: EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end

function ENT:Touch( pOther )

	assert( pOther );
	if ( pOther:GetSolid() == SOLID_NONE ) then
		return;
	end

	// If I'm live go ahead and blow up
	if (self.m_bIsLive) then
		self:Detonate();
	else
		// If I'm not live, only blow up if I'm hitting an chacter that
		// is not the owner of the weapon
		local pBCC = pOther;
		if (pBCC && self.Entity:GetOwner() != pBCC) then
			self.m_bIsLive = true;
			self:Detonate();
		end
	end

end

/*---------------------------------------------------------
   Name: OnThink
---------------------------------------------------------*/
function ENT:OnThink()
end