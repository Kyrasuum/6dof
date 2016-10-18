function SetHome(ply, cmd, args) ----------SET HOME FUNCTION----------
	start = args[1]
	file.Write( "jcwebhome.txt", start )
end
concommand.Add( "jcweb_sethome", SetHome )

include( "qmod_cfg.lua" )
include( "qmod_hud.lua" )

--You can add more links below by repeating what you see.

local quicklinks = { ----------QUICK LINKS----------
	"garrysmod.com",
	"garrysmod.org",
	"facepunch.com",
	"jokerice.co.uk",
	"youtube.com",
	"facebook.com",
	"myspace.com",
	"google.com",
	"addictinggames.com",
	"maxgames.com",
	"honcast.com",
	"justin.tv",
}

function Html()
BrowserFrame = vgui.Create( "DFrame" ) ----------BROWSER FRAME----------
BrowserFrame:SetPos( 0,0 )
BrowserFrame:SetSize( ScrW(), ScrH() )
BrowserFrame:SetTitle( "JcWeb v1.3" )
BrowserFrame:SetVisible( true )
BrowserFrame:SetDraggable( false )
BrowserFrame:ShowCloseButton( false )
BrowserFrame:SetSizable( false )
BrowserFrame:MakePopup()

BrowserPanel = vgui.Create( "DPropertySheet", BrowserFrame )
BrowserPanel:SetPos( 5,25 )
BrowserPanel:SetSize( ScrW()-10, ScrH()-30 )

MiniFrame = vgui.Create( "DFrame" ) ----------MINIMIZE FRAME----------
MiniFrame:SetVisible( false )

	local CloseButton = vgui.Create( "DButton", BrowserPanel ) ----------CLOSE BUTTON----------
	CloseButton:SetPos( BrowserPanel:GetWide()-50, 5 )
	CloseButton:SetSize( 45, 15 )
	CloseButton:SetText( "Close" )
	CloseButton.DoClick = function()
		BrowserFrame:Remove()
		btoggledon = 0
		bopened = 0
		bmini = 0
	end

	local MinButton = vgui.Create( "DButton", BrowserPanel ) ----------MINIMIZE BUTTON----------
	MinButton:SetPos( BrowserPanel:GetWide()-100, 5 )
	MinButton:SetSize( 45, 15 )
	MinButton:SetText( "Min" )
	MinButton.DoClick = function()
	BrowserFrame:SetVisible(false)
		
		btoggledon = 1
		bopened = 1
		bmini = 1
	
		if bmini == 1 then
			MiniFrame:SetPos( 160, 5 )
			MiniFrame:SetSize( 150, 18 )
			MiniFrame:SetTitle( "JcWeb v1.3" )
			MiniFrame:SetVisible( true )
			MiniFrame:SetDraggable( false )
			MiniFrame:ShowCloseButton( false )
			MiniFrame:SetSizable( false )

			local MaxButton = vgui.Create( "DButton", MiniFrame )
			MaxButton:SetPos( 0, 0 )
			MaxButton:SetSize( MiniFrame:GetWide(), MiniFrame:GetTall() )
			MaxButton:SetText( "Max" )
			
			MaxButton.DoClick = function()
			BrowserFrame:SetVisible(true)
			BrowserFrame:SetPos( 0, 0 )
			BrowserFrame:SetSize( ScrW(), ScrH() )
			
			btoggledon = 1
			bopened = 1
			bmini = 0
			
			MaxButton:SetVisible(false)
			MiniFrame:SetVisible(false)
		end
	end
end
	
	local URL = vgui.Create( "DTextEntry", BrowserPanel ) ----------NAVIGATION TOOLBAR----------
	URL:SetPos(265,24)
	URL:SetSize(BrowserPanel:GetWide()-269, 15)

	local html = vgui.Create( "HTML", BrowserPanel ) ----------HTML----------
	html:SetPos(0,44)
	html:SetSize(BrowserPanel:GetWide(), BrowserPanel:GetTall()-59)
	html:Refresh(true)
	if !file.Exists( "jcwebhome.txt", "DATA" ) then
		file.Write( "jcwebhome.txt", "google.com" )
		html:OpenURL(file.Read( "jcwebhome.txt", "DATA" ))
	else
		html:OpenURL(file.Read( "jcwebhome.txt", "DATA" ))
		URL:SetText(file.Read( "jcwebhome.txt", "DATA" ))
	end

	local Status = vgui.Create( "DTextEntry", BrowserPanel ) ----------STATUS TOOLBAR----------
	Status:SetPos(0,BrowserPanel:GetTall()-15)
	Status:SetSize(BrowserPanel:GetWide(), 15)
	Status:SetEditable( false )

	function html:OpeningURL(url, target) ----------OPENING-URL FUNCTION----------
		Status:SetText("Loading "..url.."...")
		URL:SetText( url )
		BrowserFrame:SetTitle("JcWeb v1.3 - "..url)
	end
	
	function html:StatusChanged(text)
		Status:SetText(text)
	end
	
	URL.OnEnter = function()
		local curtext = URL:GetValue()
		html:OpenURL(tostring(curtext))
		print( "Opened url: '"..tostring(curtext).."' successfully." )
	end
	
	URL.OnLoseFocus = function()
		if URL:GetValue() == "" then
			URL:SetText( "Go To URL..." )
		end
	end

	URL.OnGetFocus = function()
		if URL:GetValue() == "Go To URL..." then
			URL:SetText( "" )
		end
	end
	
	local RefreshButton = vgui.Create( "DButton", BrowserPanel ) ----------REFRESH BUTTON----------
	RefreshButton:SetPos( 145, 24 )
	RefreshButton:SetSize( 45, 15 )
	RefreshButton:SetText( "Refresh" )

	RefreshButton.DoClick = function()
		html:Refresh()
	end
	
	local HomeButton = vgui.Create( "DButton", BrowserPanel ) ----------HOME BUTTON----------
	HomeButton:SetPos( 205, 24 )
	HomeButton:SetSize( 45, 15 )
	HomeButton:SetText( "Home" )
	HomeButton.DoClick = function()
		html:OpenURL( file.Read( "jcwebhome.txt", "DATA" ) )
		URL:SetText(file.Read( "jcwebhome.txt", "DATA" ))
	end

	local QuickLinks = vgui.Create( "DButton", BrowserPanel ) ----------QUICK-LINKS BUTTON----------
	QuickLinks:SetPos( 65, 5 )
	QuickLinks:SetSize( 65, 15 )
	QuickLinks:SetText( "Quick Links" )
	QuickLinks.DoClick = function()
	local QuickLink = DermaMenu()
	for k,v in pairs( quicklinks ) do
		QuickLink:AddOption( v, function()
			html:OpenURL( v )
			URL:SetText( "http://www."..v )
		end )
	end
		QuickLink:Open()
	end
	
	local Options = vgui.Create( "DButton", BrowserPanel ) ----------OPTIONS BUTTON----------
	Options:SetPos( 5, 5 )
	Options:SetSize( 45, 15 )
	Options:SetText( "Options" )
	Options.DoClick = function()
	local options = DermaMenu()
	
	options:AddOption("Settings", function() ----------SETTINGS OPTION----------
	local jc_web_settings = vgui.Create( "DFrame" )
		jc_web_settings:SetPos( ScrW()/2-82, ScrH()/2-62 )
		jc_web_settings:SetSize( 165, 125 )
		jc_web_settings:SetTitle( "Settings" )
		jc_web_settings:SetVisible( true )
		jc_web_settings:SetDraggable( true )
		jc_web_settings:ShowCloseButton( false )
		jc_web_settings:MakePopup()
		jc_web_settings.Paint = function()
			DrawBox( 0, 0, jc_web_settings:GetWide(), 22, jc_color_bg2, 2 )
			DrawBox( 0, 21, jc_web_settings:GetWide(), jc_web_settings:GetTall()-21, jc_color_bg2, 2 )
		end
	
		local toggle_toolbar_google = vgui.Create( "DCheckBoxLabel", jc_web_settings )
		toggle_toolbar_google:SetPos( 5, 25 )
		toggle_toolbar_google:SetText( "Google Tool Bar" )
		toggle_toolbar_google:SetConVar( "jc_web_toolbar_google" )
		toggle_toolbar_google:SetValue( 1 )
		toggle_toolbar_google:SizeToContents()
		
		local toggle_googleinstant = vgui.Create( "DCheckBoxLabel", jc_web_settings )
		toggle_googleinstant:SetPos( 5, 45 )
		toggle_googleinstant:SetText( "Google Instant" )
		toggle_googleinstant:SetConVar( "jc_web_toolbar_google_instant" )
		toggle_googleinstant:SetValue( 1 )
		toggle_googleinstant:SizeToContents()
		
		local Close = vgui.Create( "DButton", jc_web_settings ) ----------CLOSE BUTTON----------
		Close:SetPos( 1, jc_web_settings:GetTall()-16 )
		Close:SetSize( jc_web_settings:GetWide()-2, 15 )
		Close:SetText( "Apply and Close" )
		Close.DoClick = function()
			jc_web_settings:Remove()
			BrowserFrame:Remove()
			RunConsoleCommand( "jc_web" )
		end
	end)
	
	local suboption = options:AddSubMenu( "Change Home URL" ) ----------CHANGE HOME OPTION----------
	suboption:AddOption( "Custom", function()
		local ChangeHomeURL = vgui.Create( "DFrame" )
		ChangeHomeURL:SetPos( (ScrW()/2)-225, (ScrH()/2)-25 )
		ChangeHomeURL:SetSize( 450, 50 )
		ChangeHomeURL:SetTitle( "Change Home URL (Example: garrysmod.com) - Current: "..file.Read( "jcwebhome.txt", "DATA" ) )
		ChangeHomeURL:SetVisible( true )
		ChangeHomeURL:SetDraggable( false )
		ChangeHomeURL:ShowCloseButton( true )
		ChangeHomeURL:SetSizable( false )
		ChangeHomeURL:MakePopup()

		local HomeURL = vgui.Create( "DTextEntry", ChangeHomeURL )
		HomeURL:SetPos( 5,26 )
		HomeURL:SetSize( 440, 20 )
		HomeURL:SetEnterAllowed( true )
		HomeURL:RequestFocus()
		HomeURL.OnEnter = function(ply, cmd, args)
			RunConsoleCommand( "jcweb_sethome", HomeURL:GetValue())
			ChangeHomeURL:Remove()
			BrowserFrame:Remove()
			RunConsoleCommand( "jc_web" )
		end
	end)
	
	suboption:AddOption( "Use Current Page", function()
		RunConsoleCommand( "jcweb_sethome", URL:GetValue())
		BrowserFrame:Remove()
		RunConsoleCommand( "jc_web" )	
	end)
	
	options:Open()
	end
	
	if tobool(LocalPlayer():GetInfoNum("jc_web_toolbar_google", 1)) then ----------GOOGLE TOOLBAR----------
		local toolbar_google = vgui.Create( "DTextEntry", BrowserPanel )
		toolbar_google:SetPos(145, 5)
		toolbar_google:SetSize(200, 15)
		toolbar_google:SetText( "Search Google..." )
		
		if tobool(LocalPlayer():GetInfoNum("jc_web_toolbar_google_instant", 1)) then
			toolbar_google.OnTextChanged = function()
				html:OpenURL("www.google.com/search?hl=en&q="..toolbar_google:GetText())
				toolbar_google:RequestFocus()
			end
			toolbar_google.OnGetFocus = function()
				if toolbar_google:GetValue() == "Search Google..." then
					toolbar_google:SetText( "" )
				end
			end
			
			toolbar_google.OnLoseFocus = function()
				if toolbar_google:GetValue() == "" then
					toolbar_google:SetText( "Search Google..." )
				end
			end
			
		else
		
			toolbar_google.OnGetFocus = function()
				if toolbar_google:GetValue() == "Search Google..." then
					toolbar_google:SetText( "" )
				end
			end
			
			toolbar_google.OnLoseFocus = function()
				if toolbar_google:GetValue() == "" then
					toolbar_google:SetText( "Search Google..." )
				end
			end
			
			toolbar_google.OnEnter = function()
				html:OpenURL("www.google.com/search?hl=en&q="..toolbar_google:GetText())
			end
		end
	end
	
	local Back = vgui.Create( "DButton", BrowserPanel ) ----------BACK BUTTON----------
	Back:SetPos( 5, 24 )
	Back:SetSize( 45, 15 )
	Back:SetText( "Back" )
	Back.DoClick = function()
		html:HTMLBack()
	end
	
	local Forward = vgui.Create( "DButton", BrowserPanel ) ----------FORWARD BUTTON----------
	Forward:SetPos( 65, 24 )
	Forward:SetSize( 65, 15 )
	Forward:SetText( "Forward" )
	Forward.DoClick = function()
		html:HTMLForward()
	end
end
concommand.Add( "jc_web", Html )
