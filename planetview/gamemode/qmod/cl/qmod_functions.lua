function DrawBox( x, y, w, h, col, s ) --originally by the maw
	if not s then s = 3 end
	
	for i = 0, s do
		draw.RoundedBox( 0, x+i, y+i, w-i*2, h-i*2, Color( col.r/i, col.g/i, col.b/i, col.a ) )
	end
end

function DrawBoxNormal( x, y, w, h, col )
	draw.RoundedBox( 0, x, y, w, h, Color( col.r, col.g, col.b, col.a ) )
end

function DrawLine(x, y, w, h, col )
	surface.SetDrawColor( col )
	surface.DrawLine( x, y, w, h )
end

function Pulsate(c) --used for flashing colors
	return (math.cos(CurTime()*c)+1)/2 --originally by the maw
end

function CursorPos(x,y,w,h) --used for un parented buttons (originally by the maw)
	local cpx,cpy = gui.MousePos()
	
	if (cpx>x)and(cpx<x+w)and(cpy>y)and(cpy<y+h) then return true end
	return false
end

B = {}

function input.MousePress(MOUSE) --MOUSE _LEFT, _RIGHT, _MIDDLE
if (input.IsMouseDown(MOUSE)) then

	if (!B[MOUSE]) then
		B[MOUSE] = true
		return true
	else
		return false
	end
	
	elseif (!input.IsKeyDown(MOUSE)) then
		if (B[MOUSE]) then B[MOUSE] = false end
	end
end

function DrawPText( text, font, x, y, col, align1, align1 )
	color = Color( Pulsate(3)*col.r, Pulsate(3)*col.g, Pulsate(3)*col.b, col.a )
	draw.SimpleText( text, font, x, y, color, align1, align2 )
end

function DrawPTextOutlined( text, font, x, y, col, align1, align2, s, col2 )
	color = Color( Pulsate(3)*col.r, Pulsate(3)*col.g, Pulsate(3)*col.b, col.a )
	draw.SimpleTextOutlined( text, font, x, y, color, align1, align2, s, col2 )
end

function DrawText( text, font, x, y, col, align1, align2 )
	draw.SimpleText( text, font, x, y, col, align1, align2 )
end

function DrawTextOutlined( text, font, x, y, col, align1, align2, s, col2 )
	color = Color( col.r, col.g, col.b, col.a )
	draw.SimpleText( text, font, x+1, y+1, jc_color_black, align1, align2 )
	draw.SimpleText( text, font, x, y, color, align1, align2 )
end