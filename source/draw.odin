package main

import gl "vendor:OpenGL"
import "utils"
import "core:math/linalg"

SpriteRenderer :: struct {
	shader: ^ShaderData,
	vao: u32
}

sprite_renderer_init :: proc(sprite_renderer: ^SpriteRenderer, shader: ^ShaderData) {
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

	sprite_renderer.shader = shader
	vbo: u32
	gl.GenVertexArrays(1, &sprite_renderer.vao)
	gl.GenBuffers(1, &vbo)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(template_vertices), raw_data(template_vertices), gl.STATIC_DRAW)

	gl.BindVertexArray(sprite_renderer.vao)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 4, gl.FLOAT, false, 4 * size_of(f32), uintptr(0))
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
}

sprite_renderer_draw :: proc(sprite_renderer: SpriteRenderer, texture: Texture, position: utils.Vec2, size: utils.Vec2, rotation_angle: f32, color: utils.Vec3) {
	ShaderData_use_program(sprite_renderer.shader^)
	model: linalg.Matrix4f32 = linalg.MATRIX4F32_IDENTITY
	model = linalg.matrix4_translate_f32({position.x, position.y, 0})

	model = linalg.matrix4_translate_f32({0.5 * size.x, 0.5 * size.y, 0.0})
	model = linalg.matrix4_rotate_f32(linalg.to_radians(rotation_angle), {0.0, 0.0, 1.0}) // On rotate autour de l'axe Z.
	model = linalg.matrix4_translate_f32({-0.5 * size.x, -0.5 * size.y, 0.0})

	model = linalg.matrix4_scale_f32({size.x, size.y, 1.0})

	model_loc := ShaderData_get_uniform_location(sprite_renderer.shader^, "model")
	ShaderData_set_uniform_matrix4fv(sprite_renderer.shader^, model_loc, model)

	color_loc := ShaderData_get_uniform_location(sprite_renderer.shader^, "sprite_color")
	ShaderData_set_uniform_3f(sprite_renderer.shader^, color_loc, color.x, color.y, color.z)

	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, texture.texture_id)

	gl.BindVertexArray(sprite_renderer.vao)
	gl.DrawArrays(gl.TRIANGLES, 0, 6)
	gl.BindVertexArray(0)
}
