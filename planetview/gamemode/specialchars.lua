/*
Just some protection for defining user groups
Database is handled here
*/
/*//==================================================================================////
								Database is handled here
*///==================================================================================////
//////Connect / Disconnect//////
//Just a little alert
function connectAlert( name, ip )
	PrintMessage( HUD_PRINTTALK, name .. " has joined the game." )
end
//This updates the player's playing time
//This also gives us a message alert
function saveTime( ply )
	local time = ply:GetPData("PlayingTime")//shortcut to access sql data on play time
	ply:SetPData( "PlayingTime", time + ply:TimeConnected()/60 )
	saveStat(ply)
	PrintMessage( HUD_PRINTTALK, ply:Name().. " has left the server." )
end
hook.Add("PlayerConnect", "ConnectAlert", connectAlert)
hook.Add("PlayerDisconnected", "SaveTime", saveTime)
///////////////////////////////

function sql_value_stats ( ply )
	local steamID = ply:SteamID()
	unique_id = sql.QueryValue("SELECT unique_id FROM player_info WHERE unique_id = '"..steamID.."'")
	money = tonumber(sql.QueryValue("SELECT money FROM player_info WHERE unique_id = '"..steamID.."'"), 10)
	permis = tonumber(sql.QueryValue("SELECT permis FROM player_info WHERE unique_id = '"..steamID.."'"), 10)
	time = tonumber(sql.QueryValue("SELECT time FROM player_info WHERE unique_id = '"..steamID.."'"), 10)
	ply:SetNWString("unique_id", unique_id)
	ply:SetNWInt("money", money)
	CheckSpecialCharacters( ply, permis )
	ply:SetPData("PlayingTime", time)//shortcut to access sql data on play time
end

 
function saveStat ( ply )
	money = ply:GetNWInt("money")
	unique_id = ply:SteamID()
	permis = ply:Team()
	time = ply:GetPData("PlayingTime")//either sql value or disconnect updated value
	sql.Query("UPDATE player_info SET money = "..money..", permis = "..permis..", time = "..time.." WHERE unique_id = '"..unique_id.."'")
	ply:ChatPrint("Stats updated!")
end
 
function tables_exist()
	if (sql.TableExists("player_info")) then
		print("tables already exist!")
	else
		if (!sql.TableExists("player_info")) then
			query = "CREATE TABLE player_info ( unique_id varchar(255), money int, permis int, time int )"
			result = sql.Query(query)
			if (sql.TableExists("player_info")) then
				print("Success! player_info table created")
			else
				print("Somthing went wrong with the player_info query!")
				print( sql.LastError( result ))
			end	
		end
	end
end
 
function new_player( steamID, ply )
		sql.Query( "INSERT INTO player_info (`unique_id`, `money`, 'permis', 'time')VALUES ('"..steamID.."', '100', '2', '0')" )
		result = sql.Query( "SELECT unique_id, money, permis, time FROM player_info WHERE unique_id = '"..steamID.."'" )
		if (result) then
			print("Player account created!")
			sql_value_stats( ply )
		else
			print("Something went wrong with creating a players info!")
		end
end
 
function player_exists( ply )
	steamID = ply:SteamID()
 
	result = sql.Query("SELECT unique_id, money, permis, time FROM player_info WHERE unique_id = '"..steamID.."'")
	if (result) then
			//they exist.  bring up values
			sql_value_stats( ply )
	else
		new_player( steamID, ply )
	end

	timer.Create("SaveStat", 120, 0, function() saveStat( ply ) end )
end

/*//==================================================================================////
								Persmissions Functions
*///==================================================================================////
//Permissions Switch Statement
function CheckSpecialCharacters( ply, permis )
	if (permis == 2) then pv_guest(ply)
	elseif (permis == 3) then pv_member(ply)
	elseif (permis == 4) then pv_admin(ply)
	elseif (permis == 5) then pv_superadmin(ply)
	elseif (permis == 6) then pv_owner(ply)
	end
end

function pv_guest( ply )
	ply:SetTeam(2)
	WelcomeMessage( ply )
end 

function pv_member( ply )
	ply:SetTeam(3)
	ReturnMessage( ply )
end 

function pv_admin( ply )
	ply:SetTeam(4)
	ReturnMessage( ply )
end 

function pv_superadmin( ply )
	ply:SetTeam(5)
	ReturnMessage( ply )
end 

function pv_owner( ply )
	ply:SetTeam(6)
	ReturnMessage( ply )
end 

//Server Join Messages
function WelcomeMessage( ply )
	ply:PrintMessage( HUD_PRINTTALK, "[PlanetView]Welcome to the server, " .. ply:Nick() )
end

function ReturnMessage( ply )
	ply:PrintMessage( HUD_PRINTTALK, "Welcome back, " .. ply:Nick() .. "\nYou connected under the IP: " .. ply:IPAddress())
	ply:PrintMessage( HUD_PRINTTALK, "You have played for " .. ply:GetPData("PlayingTime") .. " minutes." )
end