#version 330 core

out vec4 fragColor; // Output value for color of each fragment

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_texture1;
uniform sampler2D u_texture2;

const float PI = 3.1416;
const float TAU = 2* PI;

float displace(vec3 p, sampler2D tex) {
    float s = 4.5;
    float u = s / TAU * atan(p.y / p.x);
    float v = sign(p.z) / TAU * acos((p.z * p.z * sqrt(s * s + 1) + sqrt(1 - p.z * p.z * s * s)) / (p.z * p.z + 1));
    vec2 uv = 2.0 * vec2(u, v);
    float disp = texture(tex, uv).r;
    return disp * 0.06;
}

mat2 rot2D(float a){
    float sin_a = sin(a);
    float cos_a = cos(a);
    return mat2(cos_a, sin_a, -sin_a, cos_a);
}

void rotate(inout vec3 p){
    p.xy *= rot2D(sin(u_time * 0.8) * 0.25);
    p.yz *= rot2D(sin(u_time * 0.7) * 0.2);
}

float map(vec3 p){
    float dist = length(vec2(length(p.xy) - 0.6, p.z)) - 0.22; // Signed distance field for taurus
    return dist * 0.7;
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

        rotate(p);
        float hit = map(p);
        dist += hit;

        // apply displace function
        dist -= displace(0.5 * p, u_texture2);

        if (dist > 100.0 || abs(hit) < 0.0001) {
            break; // SDF always returns the shortest distance from the sphere so we can break the loop when we are too far away or too close
        }
    }
    return dist;
}

vec3 triPlanar(sampler2D tex, vec3 p, vec3 normal){
    normal = abs(normal);
    normal = pow(normal, vec3(15));
    normal /= normal.x + normal.y + normal.z;
    p = p * 0.5 + 0.5;

    return (texture(tex, p.xy) * normal.z +
            texture(tex, p.xz) * normal.y +
            texture(tex, p.yz) * normal.x).rgb;
}

vec3 render() {
    vec2 uv = (2.0 * (gl_FragCoord.xy) - u_resolution.xy) / u_resolution.y;
    vec3 color = vec3(0);

    vec3 ro = vec3(0, 0, -1.0); // Ray origin
    vec3 rd = normalize(vec3(uv, 1.0)); // Ray direction
    float dist = rayMarch(ro, rd); // Calculate distance from object

    if (dist < 100.0){
        vec3 p = ro + dist * rd;
        rotate(p);
        color += triPlanar(u_texture1, p * 1.0, getNormal(p));
    }

    return color;
}

void main(){
    vec3 color = render();
    fragColor = vec4(color, 1.0);
}