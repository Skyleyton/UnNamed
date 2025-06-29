#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texture;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec2 texture_coord;

void main() {
    gl_Position = projection * view * model * vec4(position.x, position.y, position.z, 1.0);
    texture_coord = texture;
}