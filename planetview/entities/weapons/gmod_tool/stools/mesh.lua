TOOL.Category = "Construction"
TOOL.Name = "#tool.mesh.name"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
	language.Add("tool.mesh.name", "SoftBodyMesh")
	language.Add("tool.mesh.desc", "Creates soft body meshes for use in advanced physics interaction")
	language.Add("tool.mesh.0", "Left: spawns a softbody mesh.  Right: prints the physics mesh of an object")
end

cleanup.Register( "meshes" )
function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	
	local ent = ents.Create( "prop_mesh" )
	ent:SetPos( trace.HitPos + Vector( 0, 0, 30 ) )
	ent:Spawn()

	undo.Create("mesh")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
		ply:AddCleanup( "meshes", ent )
	undo.Finish()

	ModelInit( Vector(1,1,1), 3 )
	//ent:PhysicsFromMesh(  )
	return true
end 

function TOOL:RightClick( trace )
	if (IsValid(trace.Entity)) then
		local phys = trace.Entity:GetPhysicsObject()
		if (IsValid(phys)) then
			//PrintTable(phys:GetMesh())
			local ply = self:GetOwner()
			
			local ent = ents.Create( "prop_mesh" )
			ent:SetPos( trace.HitPos + Vector( 0, 0, 30 ) )
			ent:Spawn()

			undo.Create("mesh")
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
				ply:AddCleanup( "meshes", ent )
			undo.Finish()

			ent:GetTable().model = trace.Entity:GetPhysicsObject():GetMesh()
			return true
		end
		print("No valid physics object")
		return true
	end
	print("No valid entity")
	return true
end 

function TOOL:Reload ( trace )
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "SoftBodyMesh", Description = "#tool.mesh.desc" })
end


//Create mesh
function ModelInit( size, inc )
	local verts = {}
	--amount per direction
	local vec = {}
	vec[0] = (2*size.x+1)/inc--x
	vec[1] = (2*size.y+1)/inc--y
	vec[2] = (2*size.z+1)/inc--z


	for i = 0, vec[0] do
		for j = 0, vec[1] do
			//1st triangular loop
			l = 0
			for k = 1-l, 0, -1 do
				for l = 1-k, 0, -1 do
verts[i*vec[1]+j +3-k-2*l] = {pos = Vector( size.x - (i+k)*inc, size.y - (j+l)*inc, size.z )}
				end
			end
			//2nd triangular loop
			l = 1
			for k = 1-l, 1, 1 do
				for l = 1-k, 1, 1 do
verts[i*vec[1]+j +3+2*k+l]] = {pos = Vector( size.x - (i+k)*inc, size.y - (j+l)*inc, size.z )}
				end
			end
		end
	end

	print("x: " .. x)
	print("y: " .. y)
	print("z: " .. z)
	PrintTable(verts)
end