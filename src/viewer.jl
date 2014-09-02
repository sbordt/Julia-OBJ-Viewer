using GLWindow, GLAbstraction, GLFW, ModernGL, ImmutableArrays, WavefrontObj, Gtk
using GLPlot #toopengl 

include("include.jl")

function open_obj_dialog()
	return open_dialog("Select an .obj file!", filters=("*.obj",))
end

#objpath = "../assets/models/airboat.obj"
objpath = open_obj_dialog()

assets_path = objpath[1:rsearchindex(objpath, "/")]

obj = readObjFile(objpath, faceindextype=GLuint, vertextype=Float32, compute_normals = false, triangulate = false)
computeNormals!(obj, smooth_normals = true, override = false)
triangulate!(obj)

# center geometry
obj.vertices = unitGeometry(obj.vertices)

# load mtl files if present
materials = WavefrontMtlMaterial{Float32}[]

for mtllib in obj.mtllibs
	materials = [materials, readMtlFile( assets_path*mtllib, colortype=Float32 )] 
end

# window creation
window = createwindow("OBJ-Viewer", 1000, 1000, debugging = false)
cam = PerspectiveCamera(window.inputs, Vec3(2,2,0.5), Vec3(0.0))

# render objects creation
shader = TemplateProgram("../assets/shaders/standard.vert", "../assets/shaders/phongblinn.frag")
render_objects = []

compiled_materials = Dict()

for material_name in collect(keys(obj.materials))
	(vs, nvs, uvs, fcs) = compileMaterial(obj, material_name)
	
	# hack: invert normals for glabstraction
	nvs = -nvs

	# compute index buffer for GL_LINES rendering
	lines = Vector2{GLuint}[]

	for face in fcs
		push!(lines, Vector2{GLuint}(face[1], face[2]))
		push!(lines, Vector2{GLuint}(face[2], face[3]))
		push!(lines, Vector2{GLuint}(face[1], face[3]))
	end

	# holding global references seems necessary here
	# compiled_materials[material_name] = (vs, nvs, uvs, fcs, lines)
 
	data = [
		:vertex 		=> GLBuffer(vs),
		:normal			=> GLBuffer(nvs),
		:uv				=> GLBuffer(uvs),
		:indexes		=> indexbuffer(fcs),
	#	:indexes		=> indexbuffer(lines),

		:view 			=> cam.view,
		:projection 	=> cam.projection,
		:normalmatrix	=> cam.normalmatrix,
		:model 			=> eye(Mat4),

		:light_position => Vec3(-1.0,-1.0,-1.0),
		:light_ambient 	=> Vec3(0.1,0.1,0.1),
		:light_specular => Vec3(0.9,0.9,0.9),
		:light_diffuse 	=> Vec3(1.0,1.0,1.0)
	]
	
	# search for a material with the given name
	for mtl in materials
		if mtl.name == material_name
			data[:material_ambient]  			= mtl.ambient
			data[:material_specular] 			= mtl.specular
			data[:material_diffuse]  			= mtl.diffuse
			data[:material_specular_exponent]	= mtl.specular_exponent

			if mtl.diffuse_texture != "" 
				data[:use_diffuse_texture] 	= 1.0f0
				data[:diffuse_texture] 		= Texture( assets_path*mtl.diffuse_texture )				
			else
				data[:use_diffuse_texture] 	= 0.0f0
				data[:diffuse_texture] 		= Texture( "../assets/default.png" )
			end

			break
		end
	end 

 	# default material
 	if !haskey(data, :material_ambient)
		data[:material_ambient]  			= Vec3(1.0,1.0,1.0)
		data[:material_specular] 			= Vec3(1.0,1.0,1.0)
		data[:material_diffuse] 			= Vec3(1.0,1.0,1.0)
		data[:material_specular_exponent]	= 1.0f0

		data[:use_diffuse_texture]			= 0.0f0
		data[:diffuse_texture] 				= Texture( "../assets/default.png" )
	end

	ro = RenderObject(data, shader)

	postrender!(ro, render, ro.vertexarray)
	#postrender!(ro, render, ro.vertexarray, GL_LINES)	

	render_objects = [render_objects, ro]
end

# OpenGL setup
glClearColor(0.2,0.2,0.2,1)
glDisable(GL_CULL_FACE)
glEnable(GL_DEPTH_TEST)

# Loop until the user closes the window
while !GLFW.WindowShouldClose(window.glfwWindow)

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  # render materials separately
  for ro in render_objects
  	render(ro)
  end
  
  if in(341, window.inputs[:buttonspressed].value) &&  in(79, window.inputs[:buttonspressed].value)
  	# strg + o 
  end

  yield() # this is needed for react to work

  GLFW.SwapBuffers(window.glfwWindow)
  GLFW.PollEvents()
end

GLFW.Terminate()

