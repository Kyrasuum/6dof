include( "qmod_functions.lua" )

surface.CreateFont( "JcChatText", {
	font 		= "Trebuchet18",
	size 		= 16,
	weight 		= 1000,
	antialias 	= true,
	additive 	= false,
} )

--0.5 + math.sin(SysTime()) * 0.5

function DrawText( text, font, x, y, col, align1, align2 )
	draw.SimpleText( text, font, x, y, col, align1, align2 )
end

function Pulsate(c) --used for flashing colors
	return (math.cos(CurTime()*c)+1)/2 --originally by the maw
end

local chatvisible = false
local chatshow = false
local history = {}
local spacing = 20 --Max Lines
local chatmessage = ""

chatvisible = true

local chatframe
local chatpanel
local visible
local toggledchat = 0

function SendText(pl, text)

	local hist = {
		Time = RealTime()+8,
		pl = IsValid( pl ) && pl,
		isadmin = IsValid(pl) && pl:IsAdmin(),
		text = text,
	}
	
	table.insert( history, 1, hist )
	table.remove( history, 21 )

end

alpha = 255

local y = ScrH()-155
local x = 140
local cx = x
local cy = y-155
local cw = 510

function PaintChat()
for i,v in pairs( history ) do
	if v.Time >= RealTime() or chatshow then

		if IsValid( v.pl ) then
		
			DrawTextOutlined( v.pl:Nick().."> ", "JcChatText", x-4, y-i*spacing, Color( team.GetColor( v.pl:Team()).r, team.GetColor( v.pl:Team()).g, team.GetColor( v.pl:Team()).b, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color( 0, 0, 0, 255 ) )
			
			if ( v.isadmin ) then
				DrawTextOutlined( "[Admin]", "JcChatText", x-11, y-i*spacing, Color( Pulsate(3)*255, Pulsate(3)*155, 0, alpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1, Color( 0, 0, 0, 255 ))
			else
			
			end
				
			else
			
		end
		
		DrawTextOutlined( v.text, "JcChatText", x+surface.GetTextSize( (tostring(v.pl) or "Console> "), "JcChatText" )-68, y-i*spacing, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color( 0, 0, 0, 255 ) )	
		
		end
		
	end
	
	
	if chatshow then
	
		draw.RoundedBox(0, x-64, y+4, 56, 20, Color( 25, 25, 25, alpha )) --Chat> Outline
	
		if surface.GetTextSize( chatmessage, "Default" ) >= 360 then
			draw.RoundedBox(0, x-9, y+5, 498, 18, Color( 255, 255, 255, alpha ))	
			draw.RoundedBox(0, x-10, y+4, 500, 20, Color( 25, 25, 25, alpha ))	
			
			surface.SetDrawColor( 25, 25, 25, alpha )
			surface.SetTexture(surface.GetTextureID( "gui/gradient" ))
			surface.DrawTexturedRect(x+489, y+4, 100, 1)			
			
			surface.SetDrawColor( 25, 25, 25, alpha )
			surface.SetTexture(surface.GetTextureID( "gui/gradient" ))
			surface.DrawTexturedRect(x+489, y+23, 100, 1)
			
			surface.SetDrawColor( 255, 255, 255, alpha )
			surface.SetTexture(surface.GetTextureID( "gui/gradient" ))
			surface.DrawTexturedRect(x+489, y+5, 100, 18)
			draw.RoundedBox(0, x-9, y+5, 498, 18, Color( 255, 255, 255, alpha ))
		else
			draw.RoundedBox(0, x-10, y+4, 500, 20, Color( 25, 25, 25, alpha ))	
			draw.RoundedBox(0, x-9, y+5, 498, 18, Color( 255, 255, 255, alpha ))
		end
		
		DrawTextOutlined( "Chat>", "JcChatText", x-14.5, y+5.5, Color( 255, 255, 255, alpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1, Color( 0, 0, 0, 255 ) )
		draw.SimpleText( chatmessage, "JcChatText", x-7, y+6, Color( 0, 0, 0, alpha ) )
	end
end
hook.Add( "HUDPaint","ChatPaint", PaintChat )

hook.Add("OnPlayerChat","PlayerChat",function( pl, text, teamtext, alive )
	if (IsValid(pl)) then
		SendText(pl, text, " ", rank_col)
	else
		SendText("[Server]", text, " ", Color(200,200,255,255))
	end
end)

hook.Add("ChatText","ChatText",function( playerindex, playernamename, text, filter )
	SendText(nil, text, "", Color(200,175,25,255))
	return false
end)

hook.Add("StartChat", "StartChat", function()
	chatshow = true
	return true

end)

hook.Add("FinishChat", "FinishChat", function()
	toggledchat = 0
	chatshow = false
	return true 
end)
hook.Add("ChatTextChanged", "TextChanged", function(text) chatmessage = text end)