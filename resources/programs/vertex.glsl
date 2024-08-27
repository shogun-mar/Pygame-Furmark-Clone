#version 330 core

in vec3 in_position; // Vertices of quad plane

// As of now the only thing that this does is rasterizing the whole quad in fragments.

void main() {
    gl_Position = vec4(in_position, 1.0); 
}