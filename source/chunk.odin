/* package main

import "core:fmt"

MAX_BLOCKS :: 16

Chunk :: struct {
    blocks: [MAX_BLOCKS * MAX_BLOCKS * MAX_BLOCKS]Block
}

// Init le chunk avec de la terre.
chunk_init_with_dirt :: proc(chunk: ^Chunk) {
    for x := 0; x < MAX_BLOCKS; x += 1 {
        for y := 0; y < MAX_BLOCKS; y += 1 {
            for z := 0; z < MAX_BLOCKS; z += 1 {
                chunk.blocks[x + MAX_BLOCKS * z + (MAX_BLOCKS * MAX_BLOCKS) * y].type = .DIRT
            }
        }
    }
}

chunk_get_all_blocks_position :: proc(chunk: Chunk) -> [][3]f32 {
    positions: [dynamic][3]f32

    for x := 0; x < MAX_BLOCKS; x += 1 {
        for y := 0; y < MAX_BLOCKS; y += 1 {
            for z := 0; z < MAX_BLOCKS; z += 1 {
                block_pos := [3]f32 {f32(x), f32(y), f32(z)}
                append(&positions, block_pos)
            }
        }
    }

    return positions[:]
}

chunk_get_block_at_position :: proc(chunk: Chunk, x, y, z: int) -> Block {
    if (x < 0 && x >= MAX_BLOCKS) && (y < 0 && y >= MAX_BLOCKS) && (z < 0 && z >= MAX_BLOCKS) {
        fmt.println("Hors de l'array")
        return {.AIR}
    }
    return chunk.blocks[x + MAX_BLOCKS * z + (MAX_BLOCKS * MAX_BLOCKS) * y]
}

chunk_set_block_at_position :: proc(chunk: ^Chunk, block_type: BlockType, x, y, z: int) {
    if (x < 0 && x >= MAX_BLOCKS) && (y < 0 && y >= MAX_BLOCKS) && (z < 0 && z >= MAX_BLOCKS) {
        fmt.println("Hors de l'array")
        return
    }

    chunk.blocks[x + MAX_BLOCKS * z + (MAX_BLOCKS * MAX_BLOCKS) * y].type = block_type
}

chunk_block_is_air :: proc(chunk: Chunk, x, y, z: int) -> bool {
    if (x >= 0 && x < MAX_BLOCKS) && (y >= 0 && y < MAX_BLOCKS) && (z >= 0 && z < MAX_BLOCKS) {
        if chunk_get_block_at_position(chunk, x, y, z).type != .AIR {
            return false
        }
    }
    return true
}

chunk_meshing :: proc(chunk: Chunk) -> [][3]f32 {
    vertices: [dynamic][3]f32

    for x := 0; x < MAX_BLOCKS; x += 1 {
        for y := 0; y < MAX_BLOCKS; y += 1 {
            for z := 0; z < MAX_BLOCKS; z += 1 {
                current_block := chunk_get_block_at_position(chunk, x, y, z)

                if current_block.type == .AIR {
                    // Pas besoin de faire un meshing pour l'air, c'est invisible.
                    continue
                }
                
                // TOP face
                if chunk_block_is_air(chunk, x, y + 1, z) {
                    v0 := [3]f32{f32(x),     f32(y + 1), f32(z)}
                    v1 := [3]f32{f32(x + 1), f32(y + 1), f32(z)}
                    v2 := [3]f32{f32(x + 1), f32(y + 1), f32(z + 1)}
                    v3 := [3]f32{f32(x),     f32(y + 1), f32(z + 1)}

                    append(&vertices, v0, v3, v2, v0, v2, v1)
                }
                
                // BOTTOM face
                if chunk_block_is_air(chunk, x, y - 1, z) {
                    v0 := [3]f32{f32(x),     f32(y), f32(z)}
                    v1 := [3]f32{f32(x + 1), f32(y), f32(z)}
                    v2 := [3]f32{f32(x + 1), f32(y), f32(z + 1)}
                    v3 := [3]f32{f32(x),     f32(y), f32(z + 1)}

                    append(&vertices, v0, v3, v2, v0, v2, v1)
                }

                // RIGHT face
                if chunk_block_is_air(chunk, x + 1, y, z) {
                    v0 := [3]f32{f32(x + 1), f32(y),     f32(z)}
                    v1 := [3]f32{f32(x + 1), f32(y + 1), f32(z)}
                    v2 := [3]f32{f32(x + 1), f32(y + 1), f32(z + 1)}
                    v3 := [3]f32{f32(x + 1), f32(y),     f32(z + 1)}

                    append(&vertices, v0, v1, v2, v0, v2, v3)
                }

                // LEFT face
                if chunk_block_is_air(chunk, x - 1, y, z) {
                    v0 := [3]f32{f32(x), f32(y),     f32(z)}
                    v1 := [3]f32{f32(x), f32(y),     f32(z + 1)}
                    v2 := [3]f32{f32(x), f32(y + 1), f32(z + 1)}
                    v3 := [3]f32{f32(x), f32(y + 1), f32(z)}

                    append(&vertices, v0, v1, v2, v0, v2, v3)
                }

                // FRONT face
                if chunk_block_is_air(chunk, x, y, z + 1) {
                    v0 := [3]f32{f32(x),     f32(y),     f32(z + 1)}
                    v1 := [3]f32{f32(x + 1), f32(y),     f32(z + 1)}
                    v2 := [3]f32{f32(x + 1), f32(y + 1), f32(z + 1)}
                    v3 := [3]f32{f32(x),     f32(y + 1), f32(z + 1)}

                    append(&vertices, v0, v1, v2, v0, v2, v3)
                }

                // BACK face
                if chunk_block_is_air(chunk, x, y, z - 1) {
                    v0 := [3]f32{f32(x),     f32(y),     f32(z)}
                    v1 := [3]f32{f32(x + 1), f32(y),     f32(z)}
                    v2 := [3]f32{f32(x + 1), f32(y + 1), f32(z)}
                    v3 := [3]f32{f32(x),     f32(y + 1), f32(z)}

                    append(&vertices, v0, v1, v2, v0, v2, v3)
                }

            }
        }
    }

    return vertices[:]
}

// Fais un render du chunk.
chunk_render_all_cubes :: proc(chunk: ^Chunk) {

}

chunk_render_one_call :: proc(chunk: ^Chunk) {

}
*/