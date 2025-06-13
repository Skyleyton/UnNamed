package main

import "core:fmt"
import "core:os"

import "core:math/linalg"

import "core:strings"

import gl "vendor:OpenGL"
import "vendor:glfw"


ShaderData :: struct {
    vertex_id: u32,
    fragment_id: u32,
    program_id: u32
}

ShaderData_create_program :: proc(shader: ^ShaderData) {
    shader.program_id = gl.CreateProgram()

    gl.AttachShader(shader.program_id, shader.vertex_id)
    gl.AttachShader(shader.program_id, shader.fragment_id)
    gl.LinkProgram(shader.program_id)

    success: i32
    info_log: [512]u8
    gl.GetProgramiv(shader.program_id, gl.LINK_STATUS, &success)
    if success != 1 {
        gl.GetProgramInfoLog(shader.program_id, len(info_log), nil, raw_data(info_log[:]))
    }

    gl.DeleteShader(shader.vertex_id)
    gl.DeleteShader(shader.fragment_id)
}

ShaderData_use_program :: proc(shader: ShaderData) {
    gl.UseProgram(shader.program_id)
}

/* Uniforms processing. */

ShaderData_get_uniform_location :: proc(shader: ShaderData, uniform_name: cstring) -> i32 {
    uniform_location := gl.GetUniformLocation(shader.program_id, uniform_name)
    return uniform_location
}

// Float uniforms.
ShaderData_set_uniform_float :: proc {
    ShaderData_set_uniform_1f,
    ShaderData_set_uniform_2f,
    ShaderData_set_uniform_3f,
    ShaderData_set_uniform_4f,
}

ShaderData_set_uniform_1f :: proc(shader: ShaderData, uniform_location: i32, float0: f32) {
    gl.Uniform1f(uniform_location, float0)
}

ShaderData_set_uniform_2f :: proc(shader: ShaderData, uniform_location: i32, float0, float1: f32) {
    gl.Uniform2f(uniform_location, float0, float1)
}

ShaderData_set_uniform_3f :: proc(shader: ShaderData, uniform_location: i32, float0, float1, float2: f32) {
    gl.Uniform3f(uniform_location, float0, float1, float2)
}

ShaderData_set_uniform_4f :: proc(shader: ShaderData, uniform_location: i32, float0, float1, float2, float3: f32) {
    gl.Uniform4f(uniform_location, float0, float1, float2, float3)
}

// Int uniforms.
ShaderData_set_uniform_int :: proc {
    ShaderData_set_uniform_1i,
    ShaderData_set_uniform_2i,
    ShaderData_set_uniform_3i,
    ShaderData_set_uniform_4i,
}

ShaderData_set_uniform_1i :: proc(shader: ShaderData, uniform_location: i32, i0: i32) {
    gl.Uniform1i(uniform_location, i0)
}

ShaderData_set_uniform_2i :: proc(shader: ShaderData, uniform_location: i32, i0, i1: i32) {
    gl.Uniform2i(uniform_location, i0, i1)
}

ShaderData_set_uniform_3i :: proc(shader: ShaderData, uniform_location: i32, i0, i1, i2: i32) {
    gl.Uniform3i(uniform_location, i0, i1, i2)
}

ShaderData_set_uniform_4i :: proc(shader: ShaderData, uniform_location: i32, i0, i1, i2, i3: i32) {
    gl.Uniform4i(uniform_location, i0, i1, i2, i3)
}

ShaderData_set_uniform_mat :: proc {
    ShaderData_set_uniform_matrix2fv,
    ShaderData_set_uniform_matrix3fv,
    ShaderData_set_uniform_matrix4fv,
    }

// Matrix uniforms
ShaderData_set_uniform_matrix2fv :: proc(shader: ShaderData, uniform_location: i32, mat2: linalg.Matrix2f32) {
    // WARNING: Les matrices sont en mode column major dans odin de base.
    // Donc si je flatten la matrice, ça va me donner -> 00, 10, 20, 01, 11, 21

    array := linalg.matrix_flatten(mat2) // Résout le bug du not adressable
    gl.UniformMatrix2fv(uniform_location, 1, false, raw_data(array[:]))
}

ShaderData_set_uniform_matrix3fv :: proc(shader: ShaderData, uniform_location: i32, mat3: linalg.Matrix3f32) {
    array := linalg.matrix_flatten(mat3) // Résout le bug du not adressable
    gl.UniformMatrix3fv(uniform_location, 1, false, raw_data(array[:]))
}

ShaderData_set_uniform_matrix4fv :: proc(shader: ShaderData, uniform_location: i32, mat4: linalg.Matrix4f32) {
    array := linalg.matrix_flatten(mat4) // Résout le bug du not adressable
    gl.UniformMatrix4fv(uniform_location, 1, false, raw_data(array[:]))
}
