jc_color_bg = Color( 12, 12, 12, 255 )
jc_color_bg2 = Color( 21, 21, 21, 145 )
jc_color_title = Color( 255, 255, 255, 255 )
jc_color_line = Color( 148, 148, 148, 255 )

jc_color_white 	= Color( 255, 255, 255, 255 ) 
jc_color_red 	= Color( 255, 0, 0, 255 )
jc_color_green 	= Color( 0, 255, 0, 255 )
jc_color_blue 	= Color( 0, 0, 255, 255 )
jc_color_black	= Color( 0, 0, 0, 255 )
jc_color_alpha 	= Color( 0, 0, 0, 0 )
jc_color_button = Color( 68, 87, 101, 255 )

CreateClientConVar("jc_web_toolbar_google", "1", true, true)
CreateClientConVar("jc_web_toolbar_google_instant", "0", true, true)
CreateClientConVar("jc_cfg_alf", "0", true, true)
CreateClientConVar("jc_cfg_xpl", "0", true, true)
CreateClientConVar("jc_cfg_ch", "0", true, true)
CreateClientConVar("jc_cfg_tp", "0", true, true)

toggledon = 0
btoggledon = 0
bopened = 0
bmini = 1

bw = 135
bx = (ScrW()/2)-(bw/2)
bty = 27
btw = 70
btx = (ScrW()/2)-(btw/2)

local tblFonts = { } --Credit to whoever
tblFonts["DebugFixed"] = {
	font = "Courier New",
	size = 10,
	weight = 500,
	antialias = true,
}

tblFonts["DebugFixedSmall"] = {
	font = "Courier New",
	size = 7,
	weight = 500,
	antialias = true,
}

tblFonts["DefaultFixedOutline"] = {
	font = "Lucida Console",
	size = 10,
	weight = 0,
	outline = true,
}

tblFonts["MenuItem"] = {
	font = "Tahoma",
	size = 12,
	weight = 500,
}

tblFonts["Default"] = {
	font = "Tahoma",
	size = 13,
	weight = 500,
}

tblFonts["TabLarge"] = {
	font = "Tahoma",
	size = 13,
	weight = 700,
	shadow = true,
}

tblFonts["DefaultBold"] = {
	font = "Tahoma",
	size = 13,
	weight = 1000,
}

tblFonts["DefaultUnderline"] = {
	font = "Tahoma",
	size = 13,
	weight = 500,
	underline = true,
}

tblFonts["DefaultSmall"] = {
	font = "Tahoma",
	size = 11,
	weight = 0,
}

tblFonts["DefaultSmallDropShadow"] = {
	font = "Tahoma",
	size = 11,
	weight = 0,
	shadow = true,
}

tblFonts["DefaultVerySmall"] = {
	font = "Tahoma",
	size = 10,
	weight = 0,
}

tblFonts["DefaultLarge"] = {
	font = "Tahoma",
	size = 18,
	weight = 0,
}

tblFonts["UiBold"] = {
	font = "Tahoma",
	size = 12,
	weight = 1000,
}

tblFonts["MenuLarge"] = {
	font = "Verdana",
	size = 15,
	weight = 600,
	antialias = true,
}

tblFonts["ConsoleText"] = {
	font = "Lucida Console",
	size = 10,
	weight = 500,
}

tblFonts["Marlett"] = {
	font = "Marlett",
	size = 13,
	weight = 0,
	symbol = true,
}

tblFonts["Trebuchet24"] = {
	font = "Trebuchet MS",
	size = 24,
	weight = 900,
}

tblFonts["Trebuchet22"] = {
	font = "Trebuchet MS",
	size = 22,
	weight = 900,
}

tblFonts["Trebuchet20"] = {
	font = "Trebuchet MS",
	size = 20,
	weight = 900,
}

tblFonts["Trebuchet19"] = {
	font = "Trebuchet MS",
	size = 19,
	weight = 900,
}

tblFonts["Trebuchet18"] = {
	font = "Trebuchet MS",
	size = 18,
	weight = 900,
}

tblFonts["HUDNumber"] = {
	font = "Trebuchet MS",
	size = 40,
	weight = 900,
}

tblFonts["HUDNumber1"] = {
	font = "Trebuchet MS",
	size = 41,
	weight = 900,
}

tblFonts["HUDNumber2"] = {
	font = "Trebuchet MS",
	size = 42,
	weight = 900,
}

tblFonts["HUDNumber3"] = {
	font = "Trebuchet MS",
	size = 43,
	weight = 900,
}

tblFonts["HUDNumber4"] = {
	font = "Trebuchet MS",
	size = 44,
	weight = 900,
}

tblFonts["HUDNumber5"] = {
	font = "Trebuchet MS",
	size = 45,
	weight = 900,
}

tblFonts["HudHintTextLarge"] = {
	font = "Verdana",
	size = 14,
	weight = 1000,
	antialias = true,
	additive = true,
}

tblFonts["HudHintTextSmall"] = {
	font = "Verdana",
	size = 11,
	weight = 0,
	antialias = true,
	additive = true,
}

tblFonts["CenterPrintText"] = {
	font = "Trebuchet MS",
	size = 18,
	weight = 900,
	antialias = true,
	additive = true,
}

tblFonts["DefaultFixed"] = {
	font = "Lucida Console",
	size = 10,
	weight = 0,
}

tblFonts["DefaultFixedDropShadow"] = {
	font = "Lucida Console",
	size = 10,
	weight = 0,
	shadow = true,
}

tblFonts["CloseCaption_Normal"] = {
	font = "Tahoma",
	size = 16,
	weight = 500,
}

tblFonts["CloseCaption_Italic"] = {
	font = "Tahoma",
	size = 16,
	weight = 500,
	italic = true,
}

tblFonts["CloseCaption_Bold"] = {
	font = "Tahoma",
	size = 16,
	weight = 900,
}

tblFonts["CloseCaption_BoldItalic"] = {
	font = "Tahoma",
	size = 16,
	weight = 900,
	italic = true,
}

tblFonts["TargetID"] = {
	font = "Trebuchet MS",
	size = 22,
	weight = 900,
	antialias = true,
}

tblFonts["TargetIDSmall"] = {
	font = "Trebuchet MS",
	size = 18,
	weight = 900,
	antialias = true,
}

tblFonts["BudgetLabel"] = {
	font = "Courier New",
	size = 14,
	weight = 400,
	outline = true,
}

for k,v in SortedPairs( tblFonts ) do
	surface.CreateFont( k, tblFonts[k] );
end