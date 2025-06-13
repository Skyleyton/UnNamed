package main

TextureType :: enum {
    RGB,
    RGBA
}

TextureArchetype :: enum {
    GRASS,
    ROCK3
}

Texture :: struct {
    texture_id: u32,
    width: i32,
    height: i32,
    type: TextureType,
    archetype: TextureArchetype
}
