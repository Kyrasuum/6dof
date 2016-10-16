//========= Copyright © 1996-2005, Valve Corporation, All rights reserved. ============//
//
// Purpose: Contains the implementation of game rules for multiplayer.
//
// $NoKeywords: $
//=============================================================================//

//=========================================================
//=========================================================
function IsMultiplayer( void )
	if ( server_settings.Bool( "sv_lan", 0 ) ) then
		return IsDeathmatch();
	end

	return false;
end

//=========================================================
//=========================================================
function IsDeathmatch( void )
	if ( server_settings.Bool( "deathmatch", 1 ) ) then
		return true;
	end

	return false;
end

// when we are within this close to running out of entities,  items
// marked with the ITEM_FLAG_LIMITINWORLD will delay their respawn
ENTITY_INTOLERANCE	= 100
