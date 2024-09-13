if( LocalPlayer():IsSuperAdmin() ) then
    -- adding config options for server admins

    hook.Add( "AddToolMenuCategories", "6DofCategory", function()
        spawnmenu.AddToolCategory( "Utilities", "6dof", "#6DoF" )
    end )

    hook.Add( "PopulateToolMenu", "6DofMenuSettings", function()
        spawnmenu.AddToolMenuOption( "Utilities", "6dof", "server_config", "#Server Config", "", "", function( panel )
            panel:ClearControls()
        end )
    end )
end