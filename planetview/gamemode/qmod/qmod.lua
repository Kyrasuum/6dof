local cl_files = file.Find( "qmod/cl/*.lua", "LUA" )
local sv_files = file.Find( "qmod/sv/*.lua", "LUA" )

local function qmodLoad()
	if ( SERVER ) then

		for k, v in ipairs( cl_files ) do
			AddCSLuaFile( "qmod/cl/" .. v )
		end

		for k, v in ipairs( sv_files ) do
			include( "qmod/sv/" .. v )
			print( "Quick Mod: Loaded " .. v )
		end
		
	end

	if ( CLIENT ) then
	
		for k, v in ipairs( cl_files ) do	
			include( "qmod/cl/" .. v )
			print( "Quick Mod: Loaded " .. v )
		end
		
	end

	end
qmodLoad()