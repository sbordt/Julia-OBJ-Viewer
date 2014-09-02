{{GLSL_VERSION}}

{{in}} vec2 frag_uv;
{{in}} vec3 N;
{{in}} vec3 V;

uniform vec3 material_ambient;
uniform vec3 material_specular;
uniform vec3 material_diffuse;

uniform float material_specular_exponent;

uniform vec3 light_position;
uniform vec3 light_ambient;
uniform vec3 light_specular;
uniform vec3 light_diffuse;

uniform float use_diffuse_texture;

uniform sampler2D diffuse_texture;

{{out}} vec4 fragment_color;

vec3 blinn_phong(vec3 N, vec3 V, vec3 L)
{
    float diff_coeff = max(dot(L,N), 0.0);

    // specular coefficient
    vec3 H = normalize(L+V);
    
    float spec_coeff = pow(max(dot(H,N), 0.0), material_specular_exponent);
    if (diff_coeff <= 0.0)
        spec_coeff = 0.0;

    // textures
    vec3 diffuse_tex_color = vec3(1,1,1);

    if(use_diffuse_texture == 1) 
        diffuse_tex_color = texture(diffuse_texture, frag_uv).rgb;

    // final lighting model
    return  light_ambient * material_ambient +
            light_diffuse * material_diffuse * diffuse_tex_color * diff_coeff +
            light_specular * material_specular * spec_coeff;
}


void main(){
    vec3 L = normalize(light_position - V);
    fragment_color = vec4(blinn_phong(N, V, L), 1);
}

    
            
