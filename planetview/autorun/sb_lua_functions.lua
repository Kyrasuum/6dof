
//
// The server only runs this file so it can send it to the client
//

if ( !SERVER ) then AddCSLuaFile( "sb_lua_functions.lua" ) else return end


/*---------------------------------------------------------
   Returns the path of the file it's executed in
---------------------------------------------------------*/
function GetScriptPath()

	local name	= debug.getinfo( debug.getinfo( 2, "f" ).func ).short_src
	local pos	= 0

	while true do

		local src = string.find( name, "/", ( pos || 0 ) + 1 )

		if ( !src ) then break end

		pos = src

	end

	if ( pos ) then return string.sub( name, 1, pos - 1 ) end

	return ""

end
