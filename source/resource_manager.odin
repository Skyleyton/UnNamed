package main

import "core:fmt"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

Resource_manager :: struct {
    shaders: map[string]ShaderData,
    textures: map[string]u32
}

texture_load_from_file :: proc(texture_path: cstring, texture_type: TextureType) -> Texture {
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

    texture := (Texture){
        .type = texture_type,
        .width = img_width,
        .height = img_height
    }

    return texture_id
}


compile_vertex_shader :: proc(shader: ^ShaderData, vertex_shader_filepath: string) {
    data, error := os.read_entire_file(vertex_shader_filepath)
    if !error {
        fmt.printf("Can't find the shader path: %v\n", vertex_shader_filepath)
    }
    data_str := string(data)
    data_cstring := strings.unsafe_string_to_cstring(data_str)

    shader.vertex_id = gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(shader.vertex_id, 1, &data_cstring, nil)
    gl.CompileShader(shader.vertex_id)

    success: i32
    info_log: [512]u8
    gl.GetShaderiv(shader.vertex_id, gl.COMPILE_STATUS, &success)
    if success != 1 {
        gl.GetShaderInfoLog(shader.vertex_id, len(info_log), nil, raw_data(info_log[:]))
    }
}

compile_fragment_shader :: proc(shader: ^ShaderData, fragment_shader_filepath: string) {
    data, error := os.read_entire_file(fragment_shader_filepath)
    if !error {
        fmt.printf("Can't find the shader path: %v\n", fragment_shader_filepath)
    }
    data_str := string(data)
    data_cstring := strings.unsafe_string_to_cstring(data_str)

    shader.fragment_id = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(shader.fragment_id, 1, &data_cstring, nil)
    gl.CompileShader(shader.fragment_id)

    success: i32
    info_log: [512]u8
    gl.GetShaderiv(shader.fragment_id, gl.COMPILE_STATUS, &success)
    if success != 1 {
        gl.GetShaderInfoLog(shader.fragment_id, len(info_log), nil, raw_data(info_log[:]))
    }
}

compile_shaders :: proc(shader: ^ShaderData, vertex_shader_filepath, fragment_shader_filepath: string) {
    ShaderData_compile_vertex_shader(shader, vertex_shader_filepath)
    ShaderData_compile_fragment_shader(shader, fragment_shader_filepath)
}
