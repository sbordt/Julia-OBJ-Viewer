function unitGeometry{T}(geometry::Vector{Vector3{T}}) 
	assert(!isempty(geometry))

	xmin = typemax(T)
	ymin = typemax(T)
	zmin = typemax(T)

	xmax = typemin(T)
	ymax = typemin(T)
	zmax = typemin(T)

	for vertex in geometry
		xmin = min(xmin, vertex[1])
		ymin = min(ymin, vertex[2])
		zmin = min(zmin, vertex[3])

		xmax = max(xmax, vertex[1])
		ymax = max(ymax, vertex[2])
		zmax = max(zmax, vertex[3])
	end

	xmiddle = xmin + (xmax - xmin) / 2;
	ymiddle = ymin + (ymax - ymin) / 2;
	zmiddle = zmin + (zmax - zmin) / 2;
	scale = 2 / max(xmax - xmin, ymax - ymin, zmax - zmin);

	result = similar(geometry)

	for i = 1:length(result)
		result[i] = Vector3{T}((geometry[i][1] - xmiddle) * scale,
							   (geometry[i][2] - ymiddle) * scale,
							   (geometry[i][3] - zmiddle) * scale
					);
	end

	return result
end