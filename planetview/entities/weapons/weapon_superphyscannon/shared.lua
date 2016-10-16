SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.ViewModel				= "models/weapons/c_physcannon.mdl"
SWEP.WorldModel				= "models/weapons/w_physics.mdl"
SWEP.UseHands 				= true
SWEP.ViewModelFlip			= false
SWEP.Weight 				= 42
SWEP.AutoSwitchTo 			= true
SWEP.AutoSwitchFrom 		= true
SWEP.HoldType				= "physgun"
	
SWEP.PuntForce				= 300000 -- 80000
SWEP.PullForce				= 10000
SWEP.MaxMass				= 15000 -- 250
SWEP.MaxPuntRange			= 5000 --550
SWEP.MaxPickupRange			= 850
SWEP.Distance				= 55 -- 55
	
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""
	
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= ""

SWEP.PrintName				= "Gravity Gun"
SWEP.Category = "PlanetView"
SWEP.Slot					= 1
SWEP.SlotPos				= 9

local HoldSound			= Sound("Weapon_MegaPhysCannon.HoldSound")

function SWEP:PrimaryAttack()
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.3 );
		
		local vm = self.Owner:GetViewModel()
		timer.Create( "attack_idle" .. self:EntIndex(), 0.4, 1, function()
		if !IsValid( self.Weapon ) then return end
		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		end)
		
		if self.TP then
			self:DropAndShoot()
			return
		end
		
		local trace = self.Owner:GetEyeTrace()
		local tgt = trace.Entity

		
		if !tgt or !tgt:IsValid() or (self.Owner:GetShootPos()-tgt:GetPos()):Length() > self.MaxPuntRange or self:NotAllowedClass() then
			self.Weapon:EmitSound("Weapon_MegaPhysCannon.DryFire")
			return
		end
		
		if tgt:IsNPC() and !self:AllowedClass() and !self:NotAllowedClass() or tgt:IsPlayer() then
			if (SERVER) then
				local ragdoll = ents.Create( "prop_ragdoll" )
				ragdoll:SetPos( tgt:GetPos())
				ragdoll:SetAngles(tgt:GetAngles()-Angle(tgt:GetAngles().p,0,0))
				ragdoll:SetModel( tgt:GetModel() )
				ragdoll:SetSkin( tgt:GetSkin() )
				ragdoll:SetColor( tgt:GetColor() )
				ragdoll:SetName( pickedupragdoll )
				local pickedupragdoll = ragdoll
				
			
				ragdoll:SetMaterial( tgt:GetMaterial() )
				
				ragdoll:Fire("FadeAndRemove","",120)
				
				cleanup.Add (self.Owner, "props", ragdoll);
				undo.Create ("ragdoll");
				undo.AddEntity (ragdoll);
				undo.SetPlayer (self.Owner);
				undo.Finish();
				
				if tgt:IsPlayer() then
					tgt:KillSilent()
					tgt:AddDeaths(1)
					tgt:SpectateEntity(ragdoll)
					tgt:Spectate(OBS_MODE_CHASE)

				elseif tgt:IsNPC() then
					tgt:Fire("Kill","",0)
				end
				
				self.Owner:AddFrags(1)
				
				ragdoll:Spawn()
				
				RagdollVisual(ragdoll, 1)
				
				for i = 1, ragdoll:GetPhysicsObjectCount() do
					local bone = ragdoll:GetPhysicsObjectNum(i)
					
					if bone and bone.IsValid and bone:IsValid() then
						local bonepos, boneang = tgt:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
						
						timer.Simple( 0.01, 
					function()
							bone:SetPos(bonepos)
							bone:AddVelocity(self.Owner:GetAimVector()*self.PuntForce/8)
						end )
					end
				end
			end
			self:Visual()
		end
		
		if self:AllowedClass() or tgt:GetClass() == "prop_vehicle_airboat" or tgt:GetClass() == "prop_vehicle_jeep" then
			self:Visual()
			if (SERVER) then
				local position = trace.HitPos
				tgt:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector()*self.PuntForce)
				tgt:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector()*self.PuntForce, position )
				tgt:SetPhysicsAttacker(self.Owner)
				tgt:Fire("physdamagescale","99999",0)
			end
		end
		
		if tgt:GetClass() == "prop_ragdoll" then
			self:Visual()
			if (SERVER) then
				tgt:SetPhysicsAttacker(self.Owner)
				RagdollVisual(tgt, 1)
				
				for i = 1, tgt:GetPhysicsObjectCount() do
					local bone = tgt:GetPhysicsObjectNum(i)
					
					if bone and bone.IsValid and bone:IsValid() then
						bone:AddVelocity(self.Owner:GetAimVector()*self.PuntForce/8) 
					end
				end
			end
		end
	end
	
function SWEP:SecondaryAttack()
		if self.TP then
			self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self:Drop()
			return
		end
		
		local trace = self.Owner:GetEyeTrace()
		local tgt = trace.Entity
		
		if !tgt or !tgt:IsValid() then
			return
		end
		
		if !self:NotAllowedClass() and !self:AllowedClass() then
			if (SERVER) then
				if tgt:IsNPC() or tgt:IsPlayer() then
					local ragdoll = ents.Create( "prop_ragdoll" )
					ragdoll:SetPos( tgt:GetPos())
					ragdoll:SetAngles(tgt:GetAngles()-Angle(tgt:GetAngles().p,0,0))
					ragdoll:SetModel( tgt:GetModel() )
					ragdoll:SetSkin( tgt:GetSkin() )
					ragdoll:SetColor( tgt:GetColor() )
					ragdoll:SetBodygroup( 1, tgt:GetBodygroup(1) )
					ragdoll:SetBodygroup( 2, tgt:GetBodygroup(2) )
					ragdoll:SetBodygroup( 3, tgt:GetBodygroup(3) )
					ragdoll:SetBodygroup( 4, tgt:GetBodygroup(4) )
					ragdoll:SetBodygroup( 5, tgt:GetBodygroup(5) )
					ragdoll:SetBodygroup( 6, tgt:GetBodygroup(6) )
					ragdoll:SetBodygroup( 7, tgt:GetBodygroup(7) )
					ragdoll:SetBodygroup( 8, tgt:GetBodygroup(8) )
					ragdoll:SetBodygroup( 9, tgt:GetBodygroup(9) )
					ragdoll:SetBodygroup( 10, tgt:GetBodygroup(10) )
					ragdoll:SetMaterial( tgt:GetMaterial() )
					
					cleanup.Add (self.Owner, "props", ragdoll);
					undo.Create ("ragdoll");
					undo.AddEntity (ragdoll);
					undo.SetPlayer (self.Owner);
					undo.Finish();
					
					if tgt:IsPlayer() then
						tgt:KillSilent()
						tgt:AddDeaths(1)
						tgt:SpectateEntity(ragdoll)
						tgt:Spectate(OBS_MODE_CHASE)
					elseif tgt:IsNPC() then
						tgt:Fire("Kill","",0)
					end
					
					self.Owner:AddFrags(1)
					
					ragdoll:Spawn()
					self.HP = ragdoll
					
					self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
					self.Secondary.Automatic = false
					
					self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
					self.Owner:SetAnimation( PLAYER_ATTACK1 )
					
					timer.Simple( 0.01, 
					function() 
							self:Pickup() 
						end )
				end
			end
		end
		
		if tgt:GetMoveType() == MOVETYPE_VPHYSICS then
			if (SERVER) then
				local Mass = tgt:GetPhysicsObject():GetMass()
				local Dist = (tgt:GetPos()-self.Owner:GetPos()):Length()
				local vel = self.PullForce/(Dist*0.002)
				
				if tgt:GetClass() == "prop_ragdoll" or self:AllowedClass() and tgt:GetPhysicsObject():IsMoveable() and ( !constraint.HasConstraints( tgt ) ) then
					if Dist < self.MaxPickupRange then
						self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
						self.Owner:SetAnimation( PLAYER_ATTACK1 )
						self.HP = tgt
						
						self:Pickup()
						self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
						self.Secondary.Automatic = false
					else
						tgt:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector()*-vel )
					end
				end
			end
		end
	end

function SWEP:NotAllowedClass()
		local trace = self.Owner:GetEyeTrace()
		local class = trace.Entity:GetClass()
		if class == "npc_strider"
			or class == "npc_helicopter"
			or class == "npc_combinedropship"
			or class == "npc_barnacle"
			or class == "npc_antliongrub"
			or class == "npc_turret_ceiling"
			or class == "npc_combine_camera"
			or class == "npc_combinegunship" then
		return true
		else
		return false
		end
	end
	
function SWEP:AllowedClass()
		local trace = self.Owner:GetEyeTrace()
		local class = trace.Entity:GetClass()
		if class == "npc_manhack"
			or class == "npc_turret_floor"
			or class == "npc_sscanner"
			or class == "npc_cscanner"
			or class == "npc_clawscanner"
			or class == "npc_rollermine"
			or class == "npc_grenade_frag"
			or class == "item_ammo_357"
			or class == "item_ammo_ar2_altfire"
			or class == "item_ammo_crossbow"
			or class == "item_ammo_pistol"
			or class == "item_ammo_smg1"
			or class == "item_ammo_smg1_grenade"
			or class == "item_battery"
			or class == "item_box_buckshot"
			or class == "item_healthvial"
			or class == "item_healthkit"
			or class == "item_rpg_round"
			or class == "item_ammo_ar2"
			or class == "weapon_*"
			or class == "weapon_striderbuster"
			or class == "combine_mine"
			or class == "gmod_camera"
			or class == "gmod_cameraprop"
			or class == "helicopter_chunk"
			or class == "func_physbox"
			or class == "grenade_helicopter"
			or class == "prop_wheel"
			or class == "prop_vehicle_prisoner_pod"
			or class == "prop_physics_multiplayer"
			or class == "prop_physics"
			or class == "prop_dynamic"
			or class == "func_brush"	then
		return true
	else
		return false
	end
end

function SWEP:Pickup()
		self.Weapon:EmitSound("Weapon_MegaPhysCannon.Pickup")
		self.Owner:EmitSound(HoldSound)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		
		PropLockTime = CurTime()+1
		
		timer.Simple( 0.4,
	function()
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		end )
		
		local trace = self.Owner:GetEyeTrace()
		
		self.HP:Fire("DisablePhyscannonPickup","",0)
		
		self.TP = ents.Create("prop_physics")
		if !IsValid(self.HP) then self.HP = nil return end
		self.TP:SetPos(self.HP:GetPhysicsObject():GetPos())
		self.TP:SetModel("models/props_junk/PopCan01a.mdl")
		self.TP:Spawn()
		self.TP:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self.TP:SetColor(Color(255,255,255,1))
		self.TP:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.TP:PointAtEntity(self.Owner)
		self.TP:GetPhysicsObject():SetMass(50000)
		self.TP:GetPhysicsObject():EnableMotion(false)
		
		local bone = math.Clamp(trace.PhysicsBone,0,1)
		self.Const = constraint.Weld(self.TP, self.HP, 0, bone,0,1)
		
		self.HP:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
		--self.Weapon:EmitSound(HoldSound)
	end

function SWEP:Drop()
		if !IsValid(self) then return end
		if !IsValid(self.HP) then return end
		self.HP:Fire("EnablePhyscannonPickup","",1)
		self.HP:SetCollisionGroup(COLLISION_GROUP_NONE)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		
		if self.HP:GetClass() == "prop_ragdoll" then
			RagdollVisual(self.HP, 1)
		end
		
		self.Secondary.Automatic = true
		self.Weapon:EmitSound("Weapon_MegaPhysCannon.Drop")
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 );
		
		timer.Simple( 0.4,
		function()
			if !IsValid( self.Weapon ) then return end
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end )
		
		self:TPrem()
		if self.HP then
			--self.HP = nil
		end
		
		self.Weapon:StopSound(HoldSound)
		
	end

function SWEP:DropAndShoot()
	if !IsValid(self.HP) then self.HP = nil return end
	self.HP:Fire("EnablePhyscannonPickup","",1)
	self.HP:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.HP:SetPhysicsAttacker(self.Owner)
	
	self.Secondary.Automatic = true
	
	self:Visual()
	self:TPrem()
	
	self.Weapon:StopSound(HoldSound)
	
	if self.HP:GetClass() == "prop_ragdoll" then
		local tr = self.Owner:GetEyeTrace()
	
		local dmginfo = DamageInfo();
		dmginfo:SetDamage( 500 );
		dmginfo:SetAttacker( self:GetOwner() );
		dmginfo:SetInflictor( self );
		RagdollVisual(self.HP, 1)
			
		for i = 1, self.HP:GetPhysicsObjectCount() do
			local bone = self.HP:GetPhysicsObjectNum(i)
			
			if bone and bone.IsValid and bone:IsValid() then
				timer.Simple( 0.02, 
				function() bone:AddVelocity(self.Owner:GetAimVector()*self.PuntForce/8)	end )
			end
		end
	else
		local trace = self.Owner:GetEyeTrace()
		local position = trace.HitPos
		
		timer.Simple( 0.02,
	function()
			self.HP:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector()*self.PuntForce)
			self.HP:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector()*self.PuntForce,position )
		end )
		
		self.HP:Fire("physdamagescale","9999",0)
	end
end

function SWEP:TPrem()
		if self.TP then
			if !IsValid(self.TP) then return end
			self.TP:Remove()
			self.TP = nil
		end
		
		if self.Const then
		if !IsValid(self.Const) then return end
			self.Const:Remove()
			self.Const = nil
		end
	end

function SWEP:Visual()
		self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Weapon:EmitSound( "Weapon_MegaPhysCannon.Launch" )
		
		local trace = self.Owner:GetEyeTrace()
		
		local effectdata = EffectData()
		effectdata:SetOrigin( trace.HitPos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
		util.Effect( "PhyscannonTracer", effectdata )
		--local e = EffectData()
		--e:SetEntity(trace.Entity)
		--e:SetMagnitude(30)
		--e:SetScale(30)
		--e:SetRadius(30)
		--util.Effect("TeslaHitBoxes", e)------------------------------------------------------------------------------------------------------------
		--trace.Entity:EmitSound("Weapon_StunStick.Activate")
		
		local e = EffectData()
		e:SetMagnitude(30)
		e:SetScale(30)
		e:SetRadius(30)
		e:SetOrigin(trace.HitPos)
		e:SetNormal(trace.HitNormal)
		--util.Effect("PhyscannonImpact", e)
		util.Effect("ManhackSparks", e)
	end
	
function RagdollVisual(ent, val)
if !IsValid(ent) then return end
			if ent:IsValid() then
			
			val = val+1
			
			--local effect = EffectData()
			--effect:SetEntity(ent)
			--effect:SetMagnitude(30)
			--effect:SetScale(30)
			--effect:SetRadius(30)
			--util.Effect("TeslaHitBoxes", effect)
			ent:EmitSound("Weapon_StunStick.Activate")
			
			if val <= 26 then
				timer.Simple((math.random(8,20)/100), RagdollVisual, ent, val)
			end
		end
	end

function SWEP:Deploy()
	--self.Weapon:SetNextPrimaryFire( CurTime() + 5 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 5 )
	local vm = self.Owner:GetViewModel()
	timer.Create( "deploy_idle" .. self:EntIndex(), vm:SequenceDuration(), 1, function()
	if !IsValid( self.Weapon ) then return end
	self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
	--self.Weapon:SetNextPrimaryFire( CurTime() + 0.01 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.01 )
	end)
end

function SWEP:Holster()
	timer.Destroy("deploy_idle")
	timer.Destroy("attack_idle")
	self.Weapon:StopSound(HoldSound)
	self.Weapon:Drop()
	self.HP = nil
	if self.TP then
		return false
	else
		self:TPrem()
		if self.HP then
			self.HP = nil
		end
		return true
	end
end
	
function SWEP:OnDrop()
		self:TPrem()
		if self.HP then
			self.HP = nil
		end
	end

function SWEP:Initialize()
		self:SetWeaponHoldType( self.HoldType )
		self:SetSkin(1)
	end
	
function SWEP:OwnerChanged()
		self:SetSkin(1)
		self:TPrem()
		if self.HP then
			self.HP = nil
		end
	end

function SWEP:Think()
	if CLIENT then
		if !self.Weapon:GetNWBool("Glow") then
			if !self.Owner:LookupBone("ValveBiped.Bip01_R_Hand") then return end
			local dlight = DynamicLight("lantern_"..self:EntIndex())
			if dlight then
				dlight.Pos = self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
				dlight.r = 200
				dlight.g = 255
				dlight.b = 255
				dlight.Brightness = 0.1
				dlight.Size = 70
				dlight.DieTime = CurTime() + .0001
				--dlight.Style = 0
			end
		else
			if !self.Owner:LookupBone("ValveBiped.Bip01_R_Hand") then return end
			local dlight = DynamicLight("lantern_"..self:EntIndex())
			if dlight then
				dlight.Pos = self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
				dlight.r = 255
				dlight.g = 255
				dlight.b = 255
				dlight.Brightness = 0.3
				dlight.Size = 100
				dlight.DieTime = CurTime() + .0001
				--dlight.Style = 0
			end
		end
	end
		local trace = self.Owner:GetEyeTrace()
		local tgt = trace.Entity
		
		if !self.Owner:KeyDown(IN_ATTACK) then
			if self.Owner:KeyPressed(IN_ATTACK2) then
				--if self.HP then return end   This fixes the secondary dryfire not playing
				
				if !tgt or !tgt:IsValid() then
					self.Weapon:EmitSound("Weapon_PhysCannon.TooHeavy")
					return
				end
				
				if (SERVER) then
					if tgt:GetMoveType() != MOVETYPE_VPHYSICS then
						self.Weapon:EmitSound("Weapon_PhysCannon.TooHeavy")
						return
					end
				end
			end
		
		if self.TP then
			if self.HP and self.HP != NULL then
				if (SERVER) then
				if !IsValid(self.HP) then self.HP = nil self.Drop() return end
					HPrad = self.HP:BoundingRadius()
					if !IsValid(self.Owner) then return end
					if !IsValid(self.TP) then return end
					self.TP:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*(self.Distance+HPrad))
					self.TP:PointAtEntity(self.Owner)
				--if self.HP:GetPhysicsObject() == nil then return end
				--if IsValid(phys) then
				if !IsValid(self.HP) then return end
					self.HP:GetPhysicsObject():Wake() --This needs fixing
				end --end
			else
				self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				
				self.Secondary.Automatic = true
				self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 );
				self.Weapon:EmitSound("Weapon_MegaPhysCannon.Drop")
				
				timer.Simple( 0.4, 
			function()
					self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				end )
				
				if self.TP then
					self.TP:Remove()
					self.TP = nil
				end
				if self.HP then
					self.HP = nil
				end
				
				self.Weapon:StopSound(HoldSound)
			end
			
			if CurTime() >= PropLockTime then
			if !IsValid(self.HP) then self.HP = nil return end
				if (self.HP:GetPos()-(self.Owner:GetShootPos()+self.Owner:GetAimVector()*(self.Distance+HPrad))):Length() >= 80 then
					self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
					self.Owner:SetAnimation( PLAYER_ATTACK1 )
					self:Drop()
				end
			end
		end
	end
end