function HasLineOfSight(v)
local tr = {}
	tr.start = self:GetPos()+Vector(0,0,40)
	tr.endpos = v:GetPos()+Vector(0,0,40)
	tr.filter = self
	tr = util.TraceLine(tr)
if tr.Entity == v then return true end
	return false
end


function NameTag()
for k, v in pairs( player.GetAll()) do
		if v:Alive() then
			if v:Nick() != LocalPlayer():Nick() then
				if LocalPlayer():GetPos():Distance(v:GetPos()) <= 1200 then
					pos = v:GetPos()
					pos.z = pos.z + 80
					pos = pos:ToScreen()
						
					surface.SetDrawColor( 135, 135, 135, 255 )
					surface.DrawTexturedRect(pos.x - 75, pos.y - 65, 170, 50)
					
					surface.SetDrawColor( 25, 25, 25, 255 )
					surface.DrawTexturedRect(pos.x - 74, pos.y - 64, 168, 48)
			
				if v:IsAdmin() then
					draw.SimpleTextOutlined( v:Nick(), "JcText", pos.x - 20, pos.y - 66, team.GetColor( v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color( Pulsate(3)*255, Pulsate(3)*155, 0, 255) )
				else
					DrawTextOutlined( v:Nick(), "JcText", pos.x - 20, pos.y - 66, team.GetColor( v:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color( 0, 0, 0, 255 ) )
				end
					
					surface.SetDrawColor( math.Clamp(v:Health()+95, 95, 255), 0, 0, 255 )
					surface.DrawTexturedRect(pos.x - 22, pos.y - 35, math.Clamp(v:Health()*1.16, 0, 1.16*100), 18)
					
					draw.DrawText(team.GetName(v:Team()), "Default", pos.x - 19, pos.y - 49, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT)
					draw.DrawText(team.GetName(v:Team()), "Default", pos.x - 20, pos.y - 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
					
					draw.DrawText(v:Health(), "Default", pos.x - 20, pos.y - 33, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT)
					draw.DrawText(v:Health(), "Default", pos.x - 21, pos.y - 34, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
					
					surface.SetDrawColor( team.GetColor( v:Team()).r, team.GetColor( v:Team()).g, team.GetColor( v:Team()).b, 255 )
					surface.DrawTexturedRect(pos.x - 73, pos.y - 63, 50, 46)
				end
			end
		end
	end
end
hook.Add("HUDPaint", "NameTags", NameTag)
