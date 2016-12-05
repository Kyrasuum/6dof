include('shared.lua')

//disabled default rendering and instead draws our model array
function ENT:Draw()
	self:DrawShadow(false)
	//ModelPost(self)
	return false
end

//Draw mesh
function ModelPost(ent)
	PrintTable(ent.model)
	phys = ent:GetPhysicsObject()
	if IsValid(phys) then 
		local verts = phys:GetMesh()
		local mat = ent.mat
		local mtx = Matrix()
		
		render.SetMaterial( mat )
		render.SetShadowsDisabled(true)
		mtx:Translate( ent:GetPos() )
		mtx:Rotate( ent:GetAngles() )

		cam.PushModelMatrix( mtx )
		mesh.Begin( MATERIAL_TRIANGLES, #verts ) -- Begin writing to the dynamic mesh
		for i = 1, #verts, 3 do
			local norm = ( verts[i+2].pos - verts[i].pos ):Cross( verts[i+2].pos - verts[i+1].pos )
			mesh.Position( verts[i].pos )
			mesh.Normal(norm)
			mesh.AdvanceVertex()
			mesh.Position( verts[i+1].pos )
			mesh.Normal(norm)
			mesh.AdvanceVertex()
			mesh.Position( verts[i+2].pos )
			mesh.Normal(norm)
			mesh.AdvanceVertex()
		end
		mesh.End() -- Finish writing the mesh and draw it
		cam.PopModelMatrix()
		return
	end
	//no mesh yet
end