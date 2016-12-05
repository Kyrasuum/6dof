if( CLIENT ) then
local IsHurt = false
local DrawColour = Color( 255, 255, 255, 255 )
local Alpha = 0
local maxammo = {}
local scrollheight = 0
	
	function DrawHud()
		local CLIENT = LocalPlayer()
		
		local hud = surface.GetTextureID("effects/VisorHud")
		surface.SetTexture(hud)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(0,0,ScrW(),ScrH()*1.2)
		
		if CLIENT:GetActiveWeapon():IsValid() then
			ammoleft = CLIENT:GetActiveWeapon():Clip1()
			ammoextra = CLIENT:GetAmmoCount(CLIENT:GetActiveWeapon():GetPrimaryAmmoType())
			ammosecondary = CLIENT:GetAmmoCount(CLIENT:GetActiveWeapon():GetSecondaryAmmoType())
		else
			ammoleft = 1
			ammoextra = 1
			ammosecondary = 1
		end
		if ammoleft == -1 then
			ammoleft = 0 end
		if ammoextra == -1 then
			ammoextra = 0 end
		if ammosecondary == -1 then
			ammosecondary = 0 end
		
		weapon = CLIENT:GetActiveWeapon()
		
		if CLIENT:GetActiveWeapon():IsValid() then
			if !maxammo[weapon] then
				maxammo[weapon] = CLIENT:GetActiveWeapon():Clip1()
			end
		
			draw.RoundedBox( 6, ScrW() - (ScrW()/35), ScrH()/50, ScrW()/50, (CLIENT:Health() / CLIENT:GetMaxHealth())* ScrH()/170 , Color(255,0,0,25) )
			draw.RoundedBox( 6,(ScrW()/110), ScrH()/50, ScrW()/50, ((ammoleft / maxammo[weapon]) * ScrH()/1.75) + 12, Color(0,255,0,25) )
			draw.RoundedBox( 6,(ScrW()/110), ScrH()-(ScrH()/20.57), ScrW()/11.68, (CLIENT:Armor()/100)+ScrH()/60, Color(0,255,0,25) )
			draw.SimpleText( CLIENT:Health(), "TargetID" , ScrW() - (ScrW()/15.5), (ScrH()/1.87), Color(180,180,180,25))
			draw.SimpleText( ammoleft, "TargetID" , (ScrW()/22.46), (ScrH()/1.87), Color(180,180,180,25))
			draw.SimpleText( ammoextra, "TargetIDSmall" , (ScrW()/14.07), (ScrH()/1.82), Color(180,180,180,25))
			draw.SimpleText( ammosecondary, "TargetIDSmall" , (ScrW()/10), (ScrH()/1.6), Color(180,180,180,25))
			draw.SimpleText( CLIENT:Armor(), "TargetID" , ScrW()/10.15, ScrH()-ScrH()/18, Color(180,180,180,25))
		end
		--local crosshair = surface.GetTextureID("VGUI/spacevisor/crosshair")
		local crosshair_green = surface.GetTextureID("VGUI/spacevisor/crosshair_green")
		local crosshair_red = surface.GetTextureID("VGUI/spacevisor/crosshair_red")
		local Texture = surface.GetTextureID( "VGUI/spacevisor/visorhurteffect" )
		
		local traceEnt = CLIENT:GetEyeTrace().Entity
		if  (traceEnt:IsValid() && (traceEnt:IsNPC() || traceEnt:IsPlayer() ) ) then
			local textwidth = ScrW()/ 1.94
			local textheight = ScrH()/2.095
			if ( IsFriendEntityName(traceEnt:GetClass()) ) then
				draw.SimpleText( "Allied", "Default" , textwidth, textheight, Color(0,255,0,255))
				surface.SetTexture(crosshair_green)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(ScrW()/2-(ScrW()/61.47),ScrH()/2-(ScrH()/36),ScrW()/9.344,ScrH()/18)
			else
				draw.SimpleText( "Enemy", "Default" , textwidth, textheight, Color(255,0,0,255))
				surface.SetTexture(crosshair_red)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(ScrW()/2-(ScrW()/61.47),ScrH()/2-(ScrH()/36),ScrW()/9.344,ScrH()/18)
			end
		end
			local UpdateTime = FrameTime()
	   
		if( !IsHurt ) then  
			-- Fade out  
			if( Alpha > 0 ) then  
				Alpha = math.max( Alpha - UpdateTime / 2, 0 )  -- 2 second fade out  
			end 
		else  
			-- Fade in  
			if( Alpha < 1 ) then  
				Alpha = math.min( Alpha + UpdateTime / 1.5, 1 ) -- 1.5 second fade in  
			end  
		end  

		surface.SetDrawColor( DrawColour.r, DrawColour.g, DrawColour.b, DrawColour.a * Alpha )  
		surface.SetTexture(Texture)  
		surface.DrawTexturedRect(0,0,ScrW(),ScrH())
		
		surface.SetDrawColor(255,0,0,(DrawColour.a * Alpha)/5 )    
		surface.DrawRect(0,0,ScrW(),ScrH())
	end
	hook.Add( "HUDPaint", "CustomHud", DrawHud )

	local NextCheckTime = 0
	
	function CLIENTHealthThinkHook()
		local Player = LocalPlayer()
			
		if( Player:Health() <= 0 ) then
			IsHurt = false
		end

		if( CurTime() >= NextCheckTime ) then
			if( !PreviousHealth ) then
				PreviousHealth = Player:Health()
				NextCheckTime = CurTime() + 0.1

				return
			else
				if( PreviousHealth > Player:Health() ) then
					IsHurt = true
				elseif( PreviousHealth <= Player:Health() ) then
					IsHurt = false
				end
			end

			if( IsHurt ) then
				NextCheckTime = CurTime() + 3
			else
				NextCheckTime = CurTime() + 0.1
			end
			PreviousHealth = Player:Health()
		end
	end
hook.Add( "Think", "CLIENTHealthThinkHook", CLIENTHealthThinkHook )
end
