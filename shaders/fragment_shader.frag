#version 330 core

in vec2 texture_coord;

uniform sampler2D my_texture;

out vec4 FragColor;

void main() {
    FragColor = texture(my_texture, texture_coord);
}