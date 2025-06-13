package main

import gl "vendor:OpenGL"

SpriteRenderer :: struct {
	shader: ShaderData,
	vao: i32
}

sprite_renderer_init :: proc(sprite_renderer: ^SpriteRenderer) {
	// Template pour un sprite en 2D.
	template_vertices := []f32 {
		// pos     //tex
		0.0, 1.0,  0.0, 1.0,
		0.0, 0.0,  0.0, 0.0,
		1.0, 0.0,  1.0, 0.0,

		0.0, 1.0,  0.0, 1.0,
		1.0, 0.0,  1.0, 0.0,
		1.0, 1.0,  1.0, 1.0
	}

	vbo: u32
	gl.GenVertexArrays(1, &sprite_renderer.vao)
	gl.GenBuffers(1, &vbo)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(template_vertices), template_vertices, gl.STATIC_DRAW)

	gl.BindVertexArray(sprite_renderer.vao)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 4, gl.FLOAT, false, 4 * size_of(f32), (uintptr)0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
}

sprite_renderer_draw :: proc(sprite_renderer: SpriteRenderer) {	

}
