#version 330 core
layout (location = 0) in vec4 vertices;

out vec2 texture_coord;

uniform mat4 projection;
uniform mat4 model;

void main() {
	gl_Position = projection * model * vec4(vertices.xy, 0.0, 1.0);
    texture_coord = vertices.zw;
}
