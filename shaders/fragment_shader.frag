#version 330 core

in vec2 texture_coord;

uniform sampler2D my_texture;
uniform vec3 sprite_color;

out vec4 FragColor;

void main() {
    FragColor = vec4(sprite_color, 1.0) * texture(my_texture, texture_coord);
}
