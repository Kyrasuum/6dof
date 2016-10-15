/*
Just some protection for defining user groups
*/
function CheckSpecialCharacters( ply )
	if ( ply:SteamID() == "STEAM_0:0:0"  || ply:SteamID() == "STEAM_0:1:19289341" ) then
		pv_owner(ply)
	end
	print(ply:Team())
	//Include other steamid's with their permissions here
end

function pv_guest( ply )
	ply:SetTeam(2)
	ply:PrintMessage( HUD_PRINTTALK, "[PlanetView]Welcome to the server, " .. ply:Nick() )
end 

function pv_member( ply )
	ply:SetTeam(3)
	ply:PrintMessage( HUD_PRINTTALK, "Welcome back, " .. ply:Nick() .. "\nYou connected under the IP: " .. ply:IPAddress() )
end 

function pv_admin( ply )
	ply:SetTeam(4)
	ply:PrintMessage( HUD_PRINTTALK, "Welcome back, " .. ply:Nick() .. "\nYou connected under the IP: " .. ply:IPAddress() )
end 

function pv_superadmin( ply )
	ply:SetTeam(5)
	ply:PrintMessage( HUD_PRINTTALK, "Welcome back, " .. ply:Nick() .. "\nYou connected under the IP: " .. ply:IPAddress() )
end 

function pv_owner( ply )
	ply:SetTeam(6)
	ply:PrintMessage( HUD_PRINTTALK, "Welcome back, " .. ply:Nick() .. "\nYou connected under the IP: " .. ply:IPAddress() )
end 