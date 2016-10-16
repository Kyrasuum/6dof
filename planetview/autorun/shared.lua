hook.Add("DoPlayerDeath", "drop weapon after death", function(ply)
	ply:ShouldDropWeapon(true);
end);
 
hook.Add("PlayerDeath", "drop weapon after death", function(ply)
	ply:ShouldDropWeapon(false);
end);