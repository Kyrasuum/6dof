function qmodBase()
	if (input.MousePress( MOUSE_MIDDLE )) then
		gui.EnableScreenClicker(!vgui.CursorVisible())
	end

	if( LocalPlayer():GetActiveWeapon() == "Camera" ) then return end
	
	local pl = LocalPlayer()
	
	//Box
	DrawBox( bx, -1, bw, 38, jc_color_bg2 )
	
	//Logo

	//Time	
	draw.SimpleText( os.date( "%A, %H:%M:%S" ), "DefaultSmall", bx+bw/2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	draw.SimpleText( os.date( "%m/%d/20%y" ), "DefaultSmall", bx+bw/2, 14, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

	//QMenu Button

	DrawBox( btx, bty, btw, 22, jc_color_bg2 )
	
	draw.RoundedBox( 0, btx+4, bty+4, btw-8, 14, jc_color_black )
	draw.RoundedBox( 0, btx+5, bty+5, btw-10, 12, jc_color_button )
	
	if CursorPos( btx+5, bty+5, btw-10, 12 ) then
		draw.RoundedBox( 0, btx+5, bty+5, btw-10, 12, Color( 255, 255, 255, 25 ) )
		if input.IsMouseDown( MOUSE_LEFT ) then
			draw.RoundedBox( 0, btx+5, bty+5, btw-10, 12, Color( 0, 55, 195, 60 ) )
		end
	end
	DrawTextOutlined( "Menu", "Default", btx+btw/2, bty+10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
	
if( LocalPlayer():GetActiveWeapon() == NULL ) then return end
if( !LocalPlayer():Alive() ) then return end

	if pl:InVehicle() then
		speed = math.Round( pl:GetVehicle():GetVelocity():Length() / 25.2, 0 )
	else
		speed = math.Round( pl:GetVelocity():Length() / 25.2, 0 )
	end
	
	local health = pl:Health()
	local armor = pl:Armor()
	local clip1 = pl:GetActiveWeapon():Clip1()
	local clip2 = pl:GetAmmoCount( pl:GetActiveWeapon():GetSecondaryAmmoType() )
	local mclip = pl:GetAmmoCount( pl:GetActiveWeapon():GetPrimaryAmmoType() )
	
	surface.SetFont( "Default" )

    local trace = LocalPlayer():GetEyeTrace()  
    local pos = trace.HitPos:ToScreen()  
    local gap = 5  
    local length = gap + 5

if tobool(LocalPlayer():GetInfoNum("jc_cfg_ch", 1)) then	
	if LocalPlayer():Alive() then  

		surface.SetDrawColor( 255, 0, 0, 255 ) --Red  

		--draw the crosshair  
		surface.DrawLine( pos.x + 1, pos.y + 1, pos.x + 2, pos.y + 2)  --mid
		surface.DrawLine( pos.x - length + 1, pos.y + 1, pos.x + 1 - gap, pos.y + 1 )  --left
		surface.DrawLine( pos.x + length + 1, pos.y + 1, pos.x + 2 + gap, pos.y + 1 )  --right
		surface.DrawLine( pos.x + 1, pos.y + 1 - length, pos.x + 1, pos.y - gap + 1 )  --top
		surface.DrawLine( pos.x + 1, pos.y + 1 + length, pos.x + 1, pos.y + gap + 2 )  --bottom

	end
end

hook.Add("CalcView", "MyCalcView", function(ply, pos, angles, fov)
	if tobool(LocalPlayer():GetInfoNum("jc_cfg_tp", 1)) then
	local newpos = pos + angles:Forward()*-115 + angles:Up()*3 + angles:Right()*35

    local tr = util.TraceLine {
        start = pos;    
        endpos = newpos;    
        filter = ply;    
    }    
        
    return {    
        origin = tr.HitPos;    
        angles = angles;    
        fov = fov;    
    }
	end
end)

hook.Add("ShouldDrawLocalPlayer", "ShouldDrawLocalPlayer", function(ply)
	return tobool(LocalPlayer():GetInfoNum("jc_cfg_tp", 1))
end)
	
	--armor = 100 --Test
	
	local x = 5
	local y = 5
	
	--HEALTH
	
	//Health --Health
	draw.RoundedBox( 0, x, y, 150, 18, Color( 125, 125, 125, 180 ) ) --Health Bar Background
	draw.RoundedBox( 0, x, y, math.Clamp( health, 0, 100 ) * 1.50, 18, Color( 100, 100, 200, 255 ) ) --Health Bar
	
	surface.SetDrawColor( 255, 255, 255, 55 )
	surface.SetTexture(surface.GetTextureID("gui/gradient_down")) --Health Bar Down Gradient
	surface.DrawTexturedRect(x, y, 150, 18)
	
	surface.SetDrawColor( Color( 65, 65, 65, 255 ) )
	surface.DrawOutlinedRect( x, y, 150, 18 ) --Health Bar Outline
	
	draw.SimpleText( "Health: "..health, "Default", (x + 150) / 2 - surface.GetTextSize( "Health: "..health ) / 2, y + 2, Color( 255, 255, 255, 255 ), 0, 0 )
	
	--HEALTH
	
	
	
	--ARMOR
	
	//Armor --Armor
	if armor > 0 then
	
	draw.RoundedBox( 0, x, y + 23, 150, 18, Color( 125, 125, 125, 180 ) ) --Armor Bar Background
	draw.RoundedBox( 0, x, y + 23, math.Clamp( armor, 0, 100 ) * 1.50, 18, Color( 255, 125, 10, 255 ) ) --Armor Bar
	draw.RoundedBox( 0, x, y + 23, math.Clamp( armor, 0, 100 ) * 1.50, 18, Color( 0, 0, 0, 10 ) ) --Armor Bar Mask
	
	surface.SetDrawColor( 255, 255, 255, 55 )
	surface.SetTexture( surface.GetTextureID("gui/gradient_down" )) --Armor Bar Down Gradient
	surface.DrawTexturedRect( x, y + 23, 150, 18 )
	
	surface.SetDrawColor( Color( 65, 65, 65, 255 ) )
	surface.DrawOutlinedRect( x, y + 23, 150, 18 ) --Armor Bar Outline
	
	draw.SimpleText( "Armor: "..armor, "Default", (x + 150) / 2 - surface.GetTextSize( "Armor: "..armor ) / 2, y + 23 + 2, Color( 255, 255, 255, 255 ), 0, 0 )
	
	end
	
	--ARMOR
	
	
	
	--SPEED
	
	//Speed --Speed
	if armor <= 0 then
	
	draw.RoundedBox( 0, x, y + 23, 150, 18, Color( 125, 125, 125, 180 ) )
	draw.RoundedBox( 0, x, y + 23, math.Clamp( speed, 0, 100 ) * 1.50, 18, Color( 0, 195, 25, 180 ) )
	
	surface.SetDrawColor( 255, 255, 255, 55 )
	surface.SetTexture( surface.GetTextureID("gui/gradient_down" )) --Armor Bar Down Gradient
	surface.DrawTexturedRect( x, y + 23, 150, 18)
	
	surface.SetDrawColor( Color( 65, 65, 65, 255 ) )
	surface.DrawOutlinedRect( x, y + 23, 150, 18 )

	draw.SimpleText( speed.." MPH", "Default", (x + 150) / 2 - surface.GetTextSize( speed.." MPH" ) / 2, y + 23 + 2, Color( 255, 255, 255, 255 ), 0, 0 )
	
	else

	draw.RoundedBox( 0, x, y + 46, 150, 18, Color( 125, 125, 125, 180 ) )
	draw.RoundedBox( 0, x, y + 46, math.Clamp( speed, 0, 100 ) * 1.50, 18, Color( 0, 195, 25, 180 ) )
	
	surface.SetDrawColor( 255, 255, 255, 55 )
	surface.SetTexture( surface.GetTextureID("gui/gradient_down" )) --Armor Bar Down Gradient
	surface.DrawTexturedRect( x, y + 46, 150, 18)
	
	surface.SetDrawColor( Color( 65, 65, 65, 255 ) )
	surface.DrawOutlinedRect( x, y + 46, 150, 18 )

	draw.SimpleText( speed.." MPH", "Default", (x + 150) / 2 - surface.GetTextSize( speed.." MPH" ) / 2, y + 46 + 2, Color( 255, 255, 255, 255 ), 0, 0 )
	
	end
	
	--SPEED
	
	
	
	--AMMO
	
	//Ammo --Ammo
	
	noammo = (
		pl:GetActiveWeapon():GetClass() == "weapon_physgun" or
		pl:GetActiveWeapon():GetClass() == "weapon_physgun" or
		pl:GetActiveWeapon():GetClass() == "weapon_physcannon" or
		pl:GetActiveWeapon():GetClass() == "weapon_crowbar" or
		pl:GetActiveWeapon():GetClass() == "gmod_tool"
	)
	
	if armor <= 0 then
	
	draw.RoundedBox( 0, x, y + 46, 150, 18, Color( 125, 125, 125, 180 ) ) --Ammo Bar Background
	surface.SetDrawColor( Color( 65, 65, 65, 255 ))
	surface.DrawOutlinedRect( x, y + 46, 150, 18 ) --Ammo Bar Outline
		
	if pl:GetActiveWeapon():GetClass() == "weapon_frag" or pl:GetActiveWeapon():GetClass() == "weapon_rpg" then
		
		draw.SimpleText( "["..mclip.."]", "Default", (x + 150) / 2 - surface.GetTextSize( "["..mclip.."]" ) / 2, y + 46 + 2, Color( 255, 255, 255, 255 ), 0, 0 )

	elseif noammo then
		
		draw.SimpleText( "None", "Default", (x + 150) / 2 - surface.GetTextSize( "None" ) / 2, y + 46 + 2, Color( 255, 255, 255, 255 ), 0, 0 )
		
	else

		draw.SimpleText( "["..clip1.."/"..mclip.."] "..clip2, "Default", (x + 150) / 2 - surface.GetTextSize( "["..clip1.."/"..mclip.."] "..clip2 ) / 2, y + 46 + 2, Color( 255, 255, 255, 255 ), 0, 0 )
	
	end
		
	else
	
	draw.RoundedBox( 0, x, y + 69, 150, 18, Color( 125, 125, 125, 180 ) ) --Ammo Bar Background
	surface.SetDrawColor( Color( 65, 65, 65, 255 ))
	surface.DrawOutlinedRect( x, y + 69, 150, 18 ) --Ammo Bar Outline
	
	if pl:GetActiveWeapon():GetClass() == "weapon_frag" or pl:GetActiveWeapon():GetClass() == "weapon_rpg" then
		
		draw.SimpleText( "["..mclip.."]", "Default", (x + 150) / 2 - surface.GetTextSize( "["..mclip.."]" ) / 2, y + 69 + 2, Color( 255, 255, 255, 255 ), 0, 0 )

	elseif noammo then
		
		draw.SimpleText( "None", "Default", (x + 150) / 2 - surface.GetTextSize( "None" ) / 2, y + 69 + 2, Color( 255, 255, 255, 255 ), 0, 0 )
		
	else

		draw.SimpleText( "["..clip1.."/"..mclip.."] "..clip2, "Default", (x + 150) / 2 - surface.GetTextSize( "["..clip1.."/"..mclip.."] "..clip2 ) / 2, y + 69 + 2, Color( 255, 255, 255, 255 ), 0, 0 )
	
	end
		
	end
	
	--AMMO
end
hook.Add( "HUDPaint", "qmodBase", qmodBase )

local function qmod()
if bopened == 0 then
	if CursorPos( btx+6, bty+5, btw-10, 12 ) then
		if input.MousePress(MOUSE_LEFT) then
			if toggledon == 0 then
				Menu = vgui.Create( "DFrame" )
				Menu:SetPos( btx+6, bty+17 )
				Menu:SetSize( btw-10, 33 )
				Menu:SetTitle( " " )
				Menu:SetVisible( true )
				Menu:SetDraggable( false )
				Menu:ShowCloseButton( false )
				Menu:MakePopup()
				Menu.Paint = function()
					draw.RoundedBox( 0, 0, 0, 100, 45, Color( 68, 87, 101, 255 ) )
				end
				
				toggledon = 1
				
				obutton = vgui.Create( "DButton", Menu )
				obutton:SetSize( 58, 15 )
				obutton:SetPos( 1, 1 )
				obutton:SetText( "Open..." )
				obutton.DoClick = function()
					local confirmation = DermaMenu()
					confirmation:AddOption( "Web Browser", function()
						Menu:Close()
						toggledon = 0
						bmini = 0
						
						if btoggledon == 0 && bmini == 0 then
							btoggledon = 1
							bopened = 1
							bmini = 0
							RunConsoleCommand( "jc_web" )
						end
					
					end)
					
					confirmation:AddOption( "Config", function()
						Menu:Close()
						toggledon = 0
						bmini = 0
						
						if btoggledon == 0 && bmini == 0 then
							
						btoggledon = 1
						bopened = 1
						bmini = 0

						local jc_cfg_settings = vgui.Create( "DFrame" )
							jc_cfg_settings:SetPos( ScrW()/2-82, ScrH()/2-62 )
							jc_cfg_settings:SetSize( 165, 125 )
							jc_cfg_settings:SetTitle( "Settings" )
							jc_cfg_settings:SetVisible( true )
							jc_cfg_settings:SetDraggable( true )
							jc_cfg_settings:ShowCloseButton( false )
							jc_cfg_settings:MakePopup()
							jc_cfg_settings.Paint = function()
								DrawBox( 0, 0, jc_cfg_settings:GetWide(), 22, jc_color_bg2, 2 )
								DrawBox( 0, 21, jc_cfg_settings:GetWide(), jc_cfg_settings:GetTall()-21, jc_color_bg2, 2 )
							end
						
							local toggle_jc_cfg_alf = vgui.Create( "DCheckBoxLabel", jc_cfg_settings )
							toggle_jc_cfg_alf:SetPos( 5, 25 )
							toggle_jc_cfg_alf:SetText( "Antlion Footsteps" )
							toggle_jc_cfg_alf:SetConVar( "jc_cfg_alf" )
							toggle_jc_cfg_alf:SetValue( 1 )
							toggle_jc_cfg_alf:SizeToContents()
							
							local toggle_jc_cfg_xpl = vgui.Create( "DCheckBoxLabel", jc_cfg_settings )
							toggle_jc_cfg_xpl:SetPos( 5, 45 )
							toggle_jc_cfg_xpl:SetText( "Explode on Fall" )
							toggle_jc_cfg_xpl:SetConVar( "jc_cfg_xpl" )
							toggle_jc_cfg_xpl:SetValue( 1 )
							toggle_jc_cfg_xpl:SizeToContents()
							
							local toggle_jc_cfg_xpl = vgui.Create( "DCheckBoxLabel", jc_cfg_settings )
							toggle_jc_cfg_xpl:SetPos( 5, 65 )
							toggle_jc_cfg_xpl:SetText( "Custom Crosshair" )
							toggle_jc_cfg_xpl:SetConVar( "jc_cfg_ch" )
							toggle_jc_cfg_xpl:SetValue( 1 )
							toggle_jc_cfg_xpl:SizeToContents()			

							local toggle_jc_cfg_xpl = vgui.Create( "DCheckBoxLabel", jc_cfg_settings )
							toggle_jc_cfg_xpl:SetPos( 5, 85 )
							toggle_jc_cfg_xpl:SetText( "Thirdperson" )
							toggle_jc_cfg_xpl:SetConVar( "jc_cfg_tp" )
							toggle_jc_cfg_xpl:SetValue( 1 )
							toggle_jc_cfg_xpl:SizeToContents()
							
							local Close = vgui.Create( "DButton", jc_cfg_settings ) ----------CLOSE BUTTON----------
							Close:SetPos( 1, jc_cfg_settings:GetTall()-16 )
							Close:SetSize( jc_cfg_settings:GetWide()-2, 15 )
							Close:SetText( "Apply and Close" )
							Close.DoClick = function()
								jc_cfg_settings:Remove()
								btoggledon = 0
								bopened = 0
								bmini = 0
							end
							
						end
					
					end)
					
					confirmation:Open()
				end
					
				cbutton = vgui.Create( "DButton", Menu )
				cbutton:SetSize( 58, 15 )
				cbutton:SetPos( 1, 17 )
				cbutton:SetText( "Close" )
				cbutton.DoClick = function()
					Menu:Close()
					toggledon = 0
					end
				end
			end
		end
	end
end
hook.Add( "HUDPaint", "qmod", qmod )

local function qmodHideHud( hud )

	if tobool(LocalPlayer():GetInfoNum("jc_cfg_ch", 1)) then
	
	for k, v in pairs{ "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudCrosshair" } do 
		if hud == v then 
			return false
		end
	end
	
	else
	
	for k, v in pairs{ "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo" } do 
		if hud == v then 
			return false
		end
	end
		
	end
	
end
hook.Add( "HUDShouldDraw", "qmodHideHud", qmodHideHud )