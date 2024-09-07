include('shared.lua')

//disabled default rendering and instead draws our model array
function ENT:Draw()
	self.Entity:DrawShadow(false)
	ModelPost(self.Entity)
	return false
end

//Draw mesh
function ModelPost(ent)
	local mat = ent:GetMaterial()
	local size = ent:GetNWInt("size")
	//first check if our mesh has propogated
	if size > 0 && mat != "" then
		//copy over mesh data
		local verts = {}
		for i = 1, size do
			verts[i] = ent:GetNetworkedVector("vec"..tostring(i))
		end
		local mtx = Matrix()
		
		//begin rendering and offsets
		render.SetMaterial( Material(mat) )
		render.SetShadowsDisabled(true)
		mtx:Translate( ent:GetPos() )
		mtx:Rotate( ent:GetAngles() )

		cam.PushModelMatrix( mtx )
		mesh.Begin( MATERIAL_TRIANGLES, #verts ) -- Begin writing to the dynamic mesh
		//assumes every 3 vertices make a triangle
		for i = 1, #verts, 3 do
			local norm = ( verts[i+2] - verts[i] ):Cross( verts[i+2] - verts[i+1] )//finds the surface normal
			mesh.Position( verts[i] )
			mesh.Normal(norm)
			mesh.AdvanceVertex()
			mesh.Position( verts[i+1] )
			mesh.Normal(norm)
			mesh.AdvanceVertex()
			mesh.Position( verts[i+2] )
			mesh.Normal(norm)
			mesh.AdvanceVertex()
		end
		mesh.End() -- Finish writing the mesh and draw it
		cam.PopModelMatrix()
		return
	end
	//no mesh yet
end