if( CLIENT ) then
local IsHurt = false
local DrawColour = Color( 255, 255, 255, 255 )
local Alpha = 0
local maxammo = {}
local willemit = true
local scrollheight = 0
	
	function DrawHud()
		if hudremoved == "enabled" then
			local client = LocalPlayer()
			
			local hud = surface.GetTextureID("effects/VisorHud")
			surface.SetTexture(hud)
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(0,0,ScrW(),ScrH())
			
			if client:GetActiveWeapon():IsValid() then
				ammoleft = client:GetActiveWeapon():Clip1()
				ammoextra = client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType())
				ammosecondary = client:GetAmmoCount(client:GetActiveWeapon():GetSecondaryAmmoType())
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
			
			weapon = client:GetActiveWeapon()
			
			if client:GetActiveWeapon():IsValid() then
				if !maxammo[weapon] then
					maxammo[weapon] = client:GetActiveWeapon():Clip1()
				end
			
				draw.RoundedBox( 6, ScrW() - (ScrW()/35), ScrH()/50, ScrW()/50, (client:Health() / client:GetMaxHealth())* ScrH()/170 , Color(255,0,0,25) )
				draw.RoundedBox( 6,(ScrW()/110), ScrH()/50, ScrW()/50, ((ammoleft / maxammo[weapon]) * ScrH()/1.75) + 12, Color(0,255,0,25) )
				draw.RoundedBox( 6,(ScrW()/110), ScrH()-(ScrH()/20.57), ScrW()/11.68, (client:Armor()/100)+ScrH()/60, Color(0,255,0,25) )
				draw.SimpleText( client:Health(), "TargetID" , ScrW() - (ScrW()/15.5), (ScrH()/1.87), Color(180,180,180,25))
				draw.SimpleText( ammoleft, "TargetID" , (ScrW()/22.46), (ScrH()/1.87), Color(180,180,180,25))
				draw.SimpleText( ammoextra, "TargetIDSmall" , (ScrW()/14.07), (ScrH()/1.82), Color(180,180,180,25))
				draw.SimpleText( ammosecondary, "TargetIDSmall" , (ScrW()/10), (ScrH()/1.6), Color(180,180,180,25))
				draw.SimpleText( client:Armor(), "TargetID" , ScrW()/10.15, ScrH()-ScrH()/18, Color(180,180,180,25))
			end
			--local crosshair = surface.GetTextureID("VGUI/spacevisor/crosshair")
			local crosshair_green = surface.GetTextureID("VGUI/spacevisor/crosshair_green")
			local crosshair_red = surface.GetTextureID("VGUI/spacevisor/crosshair_red")
			local Texture = surface.GetTextureID( "VGUI/spacevisor/visorhurteffect" )
			
			local traceEnt = client:GetEyeTrace().Entity
			if traceEnt:IsValid() then
				traceName = traceEnt
			else
				traceName = "Unidentified" 
			end
			local textwidth = ScrW()/ 1.94
			local textheight = ScrH()/2.095
			local sound1 = Sound("ambient/levels/prison/radio_random10.wav")
			local sound2 = Sound("ambient/levels/prison/radio_random14.wav")
			
			
			if string.match(tostring(traceName), "citizen") then
				draw.SimpleText( "Friendly", "Default" , textwidth, textheight, Color(0,255,0,255))
				surface.SetTexture(crosshair_green)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(ScrW()/2-(ScrW()/61.47),ScrH()/2-(ScrH()/36),ScrW()/9.344,ScrH()/18)
				if willemit then
					client:EmitSound(sound1,0,tonumber(math.Rand(90,110)))
					willemit = false
				end
			elseif string.match(tostring(traceName), "combine") or string.match(tostring(traceName), "metro") then
				draw.SimpleText( "Enemy Combine", "Default" , textwidth, textheight, Color(255,75,75,255))
				surface.SetTexture(crosshair_red)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(ScrW()/2-(ScrW()/61.47),ScrH()/2-(ScrH()/36),ScrW()/9.344,ScrH()/18)
				if willemit then
					client:EmitSound(sound2,0,tonumber(math.Rand(95,105)))
					willemit = false
				end
			elseif string.match(tostring(traceName), "zomb") or string.match(tostring(traceName), "headcrab")then
				draw.SimpleText( "Enemy Zombie", "Default" , textwidth, textheight, Color(255,0,0,255))
				surface.SetTexture(crosshair_red)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(ScrW()/2-(ScrW()/61.47),ScrH()/2-(ScrH()/36),ScrW()/9.344,ScrH()/18)
				if willemit then
					client:EmitSound(sound2,0,tonumber(math.Rand(95,105)))
					willemit = false
				end
			elseif string.match(tostring(traceName), "ant") or string.match(tostring(traceName), "headcrab")then
				draw.SimpleText( "Enemy Antlion", "Default" , textwidth, textheight, Color(255,0,0,255))
				surface.SetTexture(crosshair_red)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(ScrW()/2-(ScrW()/61.47),ScrH()/2-(ScrH()/36),ScrW()/9.344,ScrH()/18)
				if willemit then
					client:EmitSound(sound2,0,tonumber(math.Rand(95,105)))
					willemit = false
				end
			else
				willemit = true
			end
			
			if scrollingremoved == "enabled" then
				heightoffset = {0,20,40,60,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360,380,400,420,440,460,480,500,520,540,560,580,600,620,640,660,680,700,720,740,760,780,800}
				
				if scrollheight < ScrH()+5 then
					for k,v in pairs(heightoffset) do
						scrollheight = scrollheight + math.sin(v)
					end
				else
					scrollheight = 0
				end
				
				for k,v in pairs(heightoffset) do
				draw.SimpleText( 0, "Trebuchet24" , ScrW()/292, scrollheight + v, Color(255,0,0,25))
				end
				for k,v in pairs(heightoffset) do
				draw.SimpleText( 0, "Trebuchet24" , ScrW()/292, scrollheight + (v-ScrH()-20), Color(255,0,0,25))
				end
				
				for k,v in pairs(heightoffset) do
				draw.SimpleText( 0, "Trebuchet24" , ScrW()-(ScrW()/116.8), scrollheight + v, Color(255,0,0,25))
				end
				for k,v in pairs(heightoffset) do
				draw.SimpleText( 0, "Trebuchet24" , ScrW()-(ScrW()/116.8), scrollheight + (v-ScrH()-20), Color(255,0,0,25))
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
	end
	hook.Add( "HUDPaint", "CustomHud", DrawHud )

	local NextCheckTime = 0
	
	function ClientHealthThinkHook()
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
hook.Add( "Think", "ClientHealthThinkHook", ClientHealthThinkHook )

	function hidehud(name)
		if hudremoved == "enabled" then
			for k, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do
				if name == v then return false end
			end
		end
	end
	hook.Add("HUDShouldDraw", "hidehud", hidehud)
	if file.Read("spacehud_toggle.txt") == nil then
		file.Write("spacehud_toggle.txt","enabled")
	end
		
	hudremoved = file.Read("spacehud_toggle.txt")
	print("To disable or enable the spacevisor, type shud_toggle into your console.")

	function hudremove()
		if file.Read("spacehud_toggle.txt") == "enabled" then
			file.Write("spacehud_toggle.txt","disabled")
			hudremoved = "disabled"
		elseif file.Read("spacehud_toggle.txt") == "disabled" then
			file.Write("spacehud_toggle.txt","enabled")
			hudremoved = "enabled"
		end
	end
	concommand.Add("shud_toggle",hudremove)


	scrollingremoved = file.Read("spacehud_scrolling_toggle.txt")

	if file.Read("spacehud_scrolling_toggle.txt") == nil then
		file.Write("spacehud_scrolling_toggle.txt","enabled")
	end
		
	scrollingremoved = file.Read("spacehud_scrolling_toggle.txt")

	function scrollingremove()
		if file.Read("spacehud_scrolling_toggle.txt") == "enabled" then
			file.Write("spacehud_scrolling_toggle.txt","disabled")
			scrollingremoved = "disabled"
		elseif file.Read("spacehud_scrolling_toggle.txt") == "disabled" then
			file.Write("spacehud_scrolling_toggle.txt","enabled")
			scrollingremoved = "enabled"
		end
	end
	concommand.Add("shud_scrolling_toggle",scrollingremove)

	function info()
		print("\n==============================================================================\nTo disable or enable the spacevisor, type shud_toggle into your console.\n==============================================================================\n")
		print("==================================================================================================\nTo disable or enable the spacevisor binary scrolling effect type shud_scrolling_toggle into your console.\n==================================================================================================\n")
	end
	hook.Add("InitPostEntity", "info", info)
end
