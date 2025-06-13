package main

TextureType :: enum {
    RGB,
    RGBA
}

Texture :: struct {
    texture_id: u32,
    width: u32,
    height: u32,
    type: TextureType
}
