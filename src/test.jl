using WavefrontObj

#@time obj = readObjFile("nvidia-examples/InstancedTessellation/assets/models/Butterfly/Butterfly.obj", compute_normals = false, triangulate = false)

#objpath = "obj-viewer/assets/models/Elephant/Elephant.obj"
#objpath = "obj-viewer/assets/models/buddha.obj" # only v, vt, vt, f, double values in v
objpath = "../assets/models/airboat.obj" # g (no default), s, usemtl, faces with no material 
#objpath = "obj-viewer/assets/models/Butterfly/Butterfly.obj"

obj = readObjFile(objpath, faceindextype = Uint32, vertextype=Float32, compute_normals = false, triangulate = false)

println("$(length(obj.vertices)) vertices")
println("$(length(obj.normals)) normals")
println("$(length(obj.tex_coords)) texture coords")
println("$(length(obj.faces)) faces")
println(obj.mtllibs)
println(collect(keys(obj.materials)))
println(collect(keys(obj.groups)))
println(collect(keys(obj.smoothing_groups)))
println("-----------------------------------------------------------------------------------------------------------------------------------------------")

computeNormals!(obj, smooth_normals = true, override = true)
triangulate!(obj)

(vs_compiled, nvs_compiled, uvs_compiled, vs_material_id, fcs_compiled) = compile(obj)
# println(typeof(vs_compiled))
# println(typeof(nvs_compiled))
# println(typeof(uvs_compiled))
# println(typeof(fcs_compiled))
println("$(length(fcs_compiled)) faces")

for material in collect(keys(obj.materials))
	(vs_compiled, nvs_compiled, uvs_compiled, fcs_compiled) = compileMaterial(obj, material)
	println("material $material : $(length(fcs_compiled)) faces")
end

#mtls = readMtlFile("nvidia-examples/InstancedTessellation/assets/models/Butterfly/Butterfly.mtl")
#for mtl in mtls
#	println(mtl)
#end 