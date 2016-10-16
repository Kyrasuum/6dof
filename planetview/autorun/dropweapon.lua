function DropCurrentWeapon(ply)

	
	     local Currentweapon = ply:GetActiveWeapon()
		 
		 if !(Currentweapon && IsValid(Currentweapon)) then return end

         local NewWeapon = ents.Create(Currentweapon:GetClass())
	 
		 NewWeapon:SetClip1(Currentweapon:Clip1())
         NewWeapon:SetClip2(Currentweapon:Clip2())

         ply:StripWeapon(Currentweapon:GetClass())

		 ply.AllowWeaponPickupFix = 0

         timer.Simple(1.8, function() ply.AllowWeaponPickupFix = 1 end )
		 
         NewWeapon:SetPos(ply:GetShootPos() + (ply:GetAimVector() * 30))

         NewWeapon:Spawn()
		 local PhysWeap = NewWeapon:GetPhysicsObject()
		 if !(PhysWeap && IsValid(PhysWeap)) then NewWeapon:Remove() return end
		 
		 PhysWeap:SetVelocity((ply:GetAimVector() * 150) + ((Vector(0,0,1):Cross(ply:GetAimVector())):GetNormalized() * (math.random(0, 80) - 40)))
end

if SERVER then
concommand.Add("DropWeapon",DropCurrentWeapon)
end

function AutoBindOnSpawn(ply)
	 ply.AllowWeaponPickupFix = 1
     ply:ConCommand("bind \\ DropWeapon\n")
end

hook.Add("PlayerInitialSpawn","AutobindDropWeapon",AutoBindOnSpawn)

function RePickupFix(ply,weapon)
         if ply.AllowWeaponPickupFix == 0 then return false end
end

hook.Add("PlayerCanPickupWeapon","FixForPickup",RePickupFix)


if SERVER then
concommand.Add("Drop",DropCurrentWeapon)
end

function AutoBindOnSpawn(ply)
	 ply.AllowWeaponPickupFix = 1
     ply:ConCommand("bind \\ Drop\n")
end

hook.Add("PlayerInitialSpawn","AutobindDrop",AutoBindOnSpawn)

function RePickupFix(ply,weapon)
         if ply.AllowWeaponPickupFix == 0 then return false end
end

hook.Add("PlayerCanPickupWeapon","FixForPickup",RePickupFix)


