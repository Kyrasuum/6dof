TOOL.Category = "Construction"
TOOL.Name = "#tool.mesh.name"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Copy = {}
TOOL.Mat = ""

if CLIENT then
	language.Add("tool.mesh.name", "SoftBodyMesh")
	language.Add("tool.mesh.desc", "Creates soft body meshes for use in advanced physics interaction")
	language.Add("tool.mesh.0", "Left: spawns a softbody mesh.  Right: prints the physics mesh of an object")
end

//creates a soft body mesh
cleanup.Register( "meshes" )
function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	if (!IsValid(ply) || self.Copy == {}) then return end
	
	local ent = ents.Create( "prop_mesh" )
	ent:SetPos( trace.HitPos )
	//ent:SetMaterial( self.Mat, true )
	ent:SetMaterial( "dev/graygrid", true )

	//set our mesh data
	ent:SetNWInt("size",#self.Copy)
	for i = 1, #self.Copy do
		ent:SetNetworkedVector("vec"..tostring(i),self.Copy[i])
	end
	ent:Spawn()

	undo.Create("mesh")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
		ply:AddCleanup( "meshes", ent )
	undo.Finish()

	return true
end 

//stores the mesh geometry
function TOOL:RightClick( trace )
	if (IsValid(trace.Entity)) then
		local phys = trace.Entity:GetPhysicsObject()
		if (IsValid(phys)) then
			self.Copy = {}
			local verts = phys:GetMesh()

			for i = 1, #verts do
				self.Copy[i] = verts[i].pos
			end
			self.Mat = trace.Entity:GetMaterials()[1]
			return true
		end
		print("No valid physics object")
		return true
	end
	print("No valid entity")
	return true
end 

//nothing yet
function TOOL:Reload ( trace )
end

//the tool GUI
function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "SoftBodyMesh", Description = "#tool.mesh.desc" })
end


//Create mesh (convenience function)
function ModelInit( size, inc )
	local verts = {}
	--amount per direction
	local vec = {}
	vec[0] = (2*size.x+1)/inc--x
	vec[1] = (2*size.y+1)/inc--y
	vec[2] = (2*size.z+1)/inc--z

	//Phase loop
	//Changes use between X, Y, Z
	for p = 1, 3 do
		count = #verts
		//Loops across first phase dimension
		ip = p%3%2*vec[0]+(p+2)%3%2*vec[1]+(p+1)%3%2*vec[2]
		for i = 0, ip do
			//Loops across second phase dimension
			jp = (p+1)%3%2*vec[0]+p%3%2*vec[1]+(p+2)%3%2*vec[2]
			for j = 0, jp do
				//1st triangular loop
				l = 0
				for k = 1-l, 0, -1 do
					for l = 1-k, 0, -1 do
						print( "K: "..k )
						print( "L: "..l )
						print(" ")
verts[count +i*jp+j +3-k-2*l] = {pos = Vector( size.x - (i+k)*inc, size.y - (j+l)*inc, size.z )}
					end
				end
-- 				//2nd triangular loop
-- 				l = 1
-- 				for k = 1-l, 1, 1 do
-- 					for l = 1-k, 1, 1 do
-- verts[i*vec[1]+j +3+2*k+l]] = {pos = Vector( size.x - (i+k)*inc, size.y - (j+l)*inc, size.z )}
-- 					end
-- 				end
			end
		end
	end
	print("Thing: "..tostring(bit.bnot(math.IntToBin(0))) )
	print("Thing: "..tostring(bit.bnot(math.IntToBin(1))) )
	print("x: " .. vec[0])
	print("y: " .. vec[1])
	print("z: " .. vec[2])
	PrintTable(verts)
end