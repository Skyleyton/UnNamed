package main

import "core:fmt"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

texture_load_from_file :: proc(texture_path: cstring, texture_type: TextureType) -> u32 {
    img_width, img_height, num_channels: i32
    stbi.set_flip_vertically_on_load(1)
    img_data: [^]u8 = stbi.load(texture_path, &img_width, &img_height, &num_channels, 0)

    if img_data == nil {
        panic("Chargement des données de la texture impossible !")
    }

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    texture_id: u32
    gl.GenTextures(1, &texture_id)
    gl.BindTexture(gl.TEXTURE_2D, texture_id)

    if texture_type == .RGBA {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, img_width, img_height, 0, gl.RGBA, gl.UNSIGNED_BYTE, img_data)
    }
    else {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, img_width, img_height, 0, gl.RGB, gl.UNSIGNED_BYTE, img_data)
    }

    gl.GenerateMipmap(gl.TEXTURE_2D)

    stbi.image_free(img_data) // On aurait pu faire juste un free(img_data) [^]u8 est un rawptr si je comprends bien dans Odin.

    return texture_id
}
