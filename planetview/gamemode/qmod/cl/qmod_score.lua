include( "qmod_chat.lua" )

surface.CreateFont( "JcText", {
	font 		= "Trebuchet18",
	size 		= 16,
	weight 		= 1000,
	antialias 	= true,
	additive 	= false,
} )

surface.CreateFont( "TtText", {
	font 		= "Trebuchet18",
	size 		= 32,
	weight 		= 1000,
	antialias 	= true,
	additive 	= false,
} )

function ScoreboardShow()	
	GAMEMODE.ShowScoreboard = true --show scoreboard
	gui.SetMousePos( ScrW()/4, ScrH()/5 ) --mouse pos
	gui.EnableScreenClicker( true ) --enable mouse
	return true
end
hook.Add( "ScoreboardShow", "Show", ScoreboardShow )

function ScoreboardHide()
	GAMEMODE.ShowScoreboard = false --hide scoreboard
	gui.EnableScreenClicker( false ) --enable mouse
end
hook.Add( "ScoreboardHide", "Hide", ScoreboardHide )

--Variables
bcol = Color( 20, 20, 20, 135 ) --background color
rcol = Color( 25, 25, 25, 135 ) --button color
scol = Color( 0, 161, 255, 135 ) --standard color

local y = 115 --base y
local w = 60 --base w
local h = 20 --base h
local b = 5 --base b

local x = (ScrW()/2)-((w + 765 + (65*2))/2)-40 --base x
local tx = ((ScrW()/2)-((w + 765 + (65*2))/2))+270 --base tx (text x)

local Selected = "All"

function HUDDrawScoreBoard()

	if not GAMEMODE.ShowScoreboard then return true end

	B = {} --makes the tabs work properly

	draw.RoundedBox( 1, x + 60 - b, y - (b*2), w + 765 + (65*2), 40 + (#player.GetAll() * 15), jc_color_bg2 ) --Overall Background Bar

	draw.RoundedBox( 1, x + 62 - b, y + 2 - (b*2), w + 761 + (65*2), 36 + (#player.GetAll() * 15), jc_color_bg2 ) --Overall Background Bar #2

	draw.RoundedBox( 0, x + 65 - b, y - b, w + 755 + (65*2), 21, jc_color_bg ) --Button Background Bar
	surface.SetDrawColor( 255, 255, 255, 5 )
	surface.SetTexture(surface.GetTextureID("gui/gradient_up")) --up gradient for unselected tabs
	surface.DrawTexturedRect(x + 65 - b, y - b, w + 755 + (65*2), 20)

	
	for i = 1, 3 do --I recommend not adding tabs unless you know how, else you'll break it. Don't fucking break it.
		local Tabs = { --Scoreboard Tabs
			"General", --General Tab
			"Status", --Status Tab
			"All", --All Tab
		}
		
		DrawTextOutlined("Scoreboard - ".. Selected, "TtText", ScrW()/2, y - 44, scol, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1 )

		draw.RoundedBox( 0, x + (65 * i), y, w, 15, bcol ) --background box
		
		surface.SetDrawColor( 25, 25, 25, 255 )
		
		if Selected != Tabs[i] then --for the tabs that are not selected
			surface.SetDrawColor( 255, 255, 255, 15 )
			surface.SetTexture(surface.GetTextureID("gui/gradient_up")) --up gradient for unselected tabs
			surface.DrawTexturedRect(x + (65 * i), y, w, 15)
		end

		if Selected == Tabs[i] then --for the tab that is selected
			surface.SetDrawColor( 255, 255, 255, 15 )
			surface.SetTexture(surface.GetTextureID("gui/gradient_down")) --down gradient for selected tab
			surface.DrawTexturedRect(x + (65 * i), y, w, 15)
		end
		
		if CursorPos( x + (65 * i), y, w, 15 ) && Selected != Tabs[i] then
			draw.RoundedBox( 0, x + (65 * i), y, w, 15, Color( 255, 255, 255, 15 ) )
			
			if input.MousePress(MOUSE_LEFT) then
				Selected = Tabs[i]
			end
		
		end
		
		DrawTextOutlined( Tabs[i] , "JcText", x + 3 + (65 * i), y-1, Color( 0, 161, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1 )
		
		draw.RoundedBox( 0, x + 65 - b, y + 16, w + 755 + (65*2), 10 + ( #player.GetAll()*15 ), rcol )
		
		for k,v in pairs( player.GetAll() ) do
			
			if CursorPos( x + 63, y + 5 + (k * 15), w + 747 + (65*2), 16 ) then
				draw.RoundedBox( 0, x + 64, y + 6 + (k * 15), w + 745 + (65*2), 15, Color( 255, 255, 255, 5 ) )				
			end

				DrawTextOutlined("Ping: "..v:Ping(), "JcText", tx + 625, (y + b - 1) + (k * 15), scol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1 )
				
			if Selected == "General" then
			
			DrawTextOutlined( v:Nick(), "JcText", x + 66, (y + b - 1) + (k * 15), team.GetColor( v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1 )
			
				if !v:Alive() then
					DrawTextOutlined("Dead", "JcText", tx + 590, (y + b - 1) + (k * 15), Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1 )
				else
					DrawTextOutlined("Alive", "JcText", tx + 590, (y + b - 1) + (k * 15), Color( 0, 255, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1 )
				end
				
			elseif Selected == "Status" then
			
			DrawTextOutlined( v:Nick(), "JcText", x + 66, (y + b - 1) + (k * 15), team.GetColor( v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1 )

				if v:IsAdmin() then
					DrawTextOutlined( "[Admin]", "JcText", tx + 575, (y + b - 1) + (k * 15), Color( Pulsate(3)*255, Pulsate(3)*155, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1, Color( 0, 0, 0, 255 ) )			
				else

				end
				
			elseif Selected == "All" then
			DrawTextOutlined( v:Nick(), "JcText", x + 66, (y + b - 1) + (k * 15), team.GetColor( v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1 )
			if v:IsAdmin() then
				draw.SimpleTextOutlined( v:Nick(), "JcText", x + 66, (y + b - 1) + (k * 15), team.GetColor( v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color( Pulsate(3)*255, Pulsate(3)*155, 0, 255) )			
			else
				DrawTextOutlined( v:Nick(), "JcText", x + 66, (y + b - 1) + (k * 15), team.GetColor( v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1 )
			end
			
				if !v:Alive() then
					DrawTextOutlined("Dead", "JcText", tx + 450, (y + b - 1) + (k * 15), Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1 )
				else
					DrawTextOutlined("Alive", "JcText", tx + 450, (y + b - 1) + (k * 15), Color( 0, 255, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1 )
				end
			
				Team = team.GetName(v:Team())
			
				DrawTextOutlined(Team, "JcText", tx + 380, (y + b - 1) + (k * 15), team.GetColor(v:Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1, Color( 0, 0, 0, 255 ) )
				DrawTextOutlined("Kills: "..v:GetNWInt( "Kills" ), "JcText", tx + 505, (y + b - 1) + (k * 15), scol, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1, Color( 0, 0, 0, 255 ) )
				DrawTextOutlined("Deaths: "..v:Deaths(), "JcText", tx + 575, (y + b - 1) + (k * 15), scol, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT, 1, Color( 0, 0, 0, 255 ) )
			end	
		end
	end
end
hook.Add( "HUDDrawScoreBoard", "Draw", HUDDrawScoreBoard )