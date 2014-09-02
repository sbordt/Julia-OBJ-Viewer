{{GLSL_VERSION}}

{{in}} vec3 vertex;
{{in}} vec3 normal;
{{in}} vec3 uv;

{{out}} vec2 frag_uv;
{{out}} vec3 N;
{{out}} vec3 V;

uniform mat4 view, projection, model;
uniform mat3 normalmatrix;

void main(){
	frag_uv = uv.xy;
	V = vec3(view  * vec4(vertex,1.0));       
   	N = normalize(normalmatrix * normal);
   	
   	gl_Position = projection * view * model * vec4(vertex, 1.0);
}