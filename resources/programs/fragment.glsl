#version 330 core

out vec4 fragColor; // Output value for color of each fragment

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_texture1;

float map(vec3 p){
    float dist = length(p) - 0.6; // Signed distance field: SDF sphere: length(p) - radius
    return dist;
}

vec3 getNormal(vec3 p){
    vec2 e = vec2(0.01, 0.0);
    vec3 n = vec3(map(p)) - vec3(map(p - e.xyy), map(p - e.yxy), map(p - e.yyx)); 

    return normalize(n);
}

float rayMarch(vec3 ro, vec3 rd){
    float dist = 0.0;

    for (int i = 0; i < 256; i++){
        vec3 p = ro + dist * rd;

        float hit = map(p);
        dist += hit;

        if (dist > 100.0 || abs(hit) < 0.0001) {
            break; // SDF always returns the shortest distance from the sphere so we can break the loop when we are too far away or too close
        }
    }
    return dist;
}

vec3 render() {
    vec2 uv = (2.0 * (gl_FragCoord.xy) - u_resolution.xy) / u_resolution.y;
    vec3 color = vec3(0);

    vec3 ro = vec3(0, 0, -1.0); // Ray origin
    vec3 rd = normalize(vec3(uv, 1.0)); // Ray direction
    float dist = rayMarch(ro, rd); // Calculate distance from object

    if (dist < 100.0){
        vec3 p = ro + dist * rd
        color += getNormal(p) * 0.5 + 0.5;
    }

    return color;
}

void main(){
    vec3 color = render();
    fragColor = vec4(color, 1.0);
}