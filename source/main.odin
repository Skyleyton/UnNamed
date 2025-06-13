package main

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:math/linalg"

// rendering imports
import "vendor:glfw"
import gl "vendor:OpenGL"

// Audio imports
import ma "vendor:miniaudio"

// Image imports
import stbi "vendor:stb/image"

WIN_WIDTH :: 1280
WIN_HEIGHT :: 720

last_x := WIN_WIDTH / 2.0
last_y := WIN_HEIGHT / 2.0

first_mouse := true

State :: struct {
    window_handle: glfw.WindowHandle,

    // Audio things test.
    audio_engine: ma.engine,
    audio_playing: bool, // To know if the song is already playing, maybe I should take a reference to the song to know if it's not nil.
    resource_manager: Resource_manager,
    sprite_renderer: SpriteRenderer
}

// GLFW things.
custom_init :: proc() {
    if !glfw.Init() do panic("Erreur d'initialisation de GLFW !")

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
}

custom_end :: proc() {
    glfw.Terminate()
}

// AUDIO things.
audio_init :: proc(state: ^State) {
    result := ma.engine_init(nil, &state.audio_engine)
    if result != .SUCCESS do panic("Failed to initialize miniaudio engine !")
}

audio_end :: proc(state: ^State) {
    ma.engine_uninit(&state.audio_engine)
}

// WINDOW things.

// J'indique l'obligation de retourner quelque chose avec ce @.
@(require_results)
window_create :: proc(width, height: i32, title: cstring, monitor: glfw.MonitorHandle=nil, share: glfw.WindowHandle=nil) -> glfw.WindowHandle {
    win_handle := glfw.CreateWindow(width, height, title, monitor, share)

    return win_handle
}

window_destroy :: proc(window: glfw.WindowHandle) {
    glfw.DestroyWindow(window)
}

// INPUT things.
custom_process_input :: proc(state: ^State, dt: f32) {
    if glfw.GetKey(state.window_handle, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(state.window_handle, true)
    }

    if glfw.GetKey(state.window_handle, glfw.KEY_TAB) == glfw.PRESS {
        gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
    }
    else if glfw.GetKey(state.window_handle, glfw.KEY_TAB) == glfw.RELEASE {
        gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
    }

    if glfw.GetKey(state.window_handle, glfw.KEY_D) == glfw.PRESS {
        Camera_process_keyboard_input(&camera, .RIGHT, dt)
    }
    if glfw.GetKey(state.window_handle, glfw.KEY_A) == glfw.PRESS {
        Camera_process_keyboard_input(&camera, .LEFT, dt)
    }
    if glfw.GetKey(state.window_handle, glfw.KEY_W) == glfw.PRESS {
        Camera_process_keyboard_input(&camera, .UP, dt)
    }
    if glfw.GetKey(state.window_handle, glfw.KEY_S) == glfw.PRESS {
        Camera_process_keyboard_input(&camera, .DOWN, dt)
    }

    if glfw.GetKey(state.window_handle, glfw.KEY_LEFT_ALT) == glfw.RELEASE {
        glfw.SetInputMode(state.window_handle, glfw.CURSOR, glfw.CURSOR_DISABLED)
    }
    else if glfw.GetKey(state.window_handle, glfw.KEY_LEFT_ALT) == glfw.PRESS {
        glfw.SetInputMode(state.window_handle, glfw.CURSOR, glfw.CURSOR_NORMAL)
    }

    // test audio
    if glfw.GetKey(state.window_handle, glfw.KEY_K) == glfw.PRESS && !state.audio_playing {
        state.audio_playing = true
        ma.engine_play_sound(&state.audio_engine, "assets/Rick_Astley__Never_Gonna_Give_You_Up.mp3", nil)
    }
}

custom_clear :: proc(color: [4]f32) {
    gl.ClearColor(color.r, color.g, color.b, color.a)
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

// RENDER things
custom_render :: proc() {
    custom_clear({1.0, 1.0, 1.0, 1.0})
}

state: State
camera: Camera
dt: f32 = 0
main :: proc() {
    camera = Camera_new(linalg.Vector3f32{1.0, 1.0, 17.0})

    custom_init(); defer custom_end()
    state.window_handle = window_create(WIN_WIDTH, WIN_HEIGHT, "Vex"); defer window_destroy(state.window_handle)
    if state.window_handle == nil {
        custom_end()
        panic("Erreur de création de fenêtre !")
    }

    glfw.MakeContextCurrent(state.window_handle)

    // https://gist.github.com/SorenSaket/155afe1ec11a79def63341c588ade329
    gl.load_up_to(3, 3, glfw.gl_set_proc_address) // Pour charger les fonctions d'OpenGL.

    gl.Viewport(0, 0, WIN_WIDTH, WIN_HEIGHT)
    glfw.SetFramebufferSizeCallback(state.window_handle, window_framebuffer_size_callback) // Register the callback function.
    glfw.SetWindowRefreshCallback(state.window_handle, window_framebuffer_refresh_callback)
    glfw.SetCursorPosCallback(state.window_handle, mouse_input_callback);
    glfw.SetScrollCallback(state.window_handle, mouse_scroll_input_callback);


    // Audio test with miniaudio
    // audio_engine: ma.engine
    audio_init(&state); defer audio_end(&state)

    // Init du système
    shader: ShaderData
    load_texture_into_resource_manager(&state.resource_manager, "assets/rock3.png", .RGBA, .ROCK3)
    compile_vertex_shader(&shader, "shaders/vertex_shader.vert")
    compile_fragment_shader(&shader, "shaders/fragment_shader.frag")
    ShaderData_create_program(&shader)
    put_shader_in_resource_manager(&state.resource_manager, &shader, "basic_shader")
    projection: linalg.Matrix4f32 = linalg.matrix_ortho3d_f32(0.0, WIN_WIDTH, WIN_HEIGHT, 0.0, -1.0, 1.0)

    ShaderData_use_program(get_shader_from_resource_manager(state.resource_manager, "basic_shader"))
    my_texture := ShaderData_get_uniform_location(shader, "my_texture")
    proj := ShaderData_get_uniform_location(shader, "projection")
    ShaderData_set_uniform_1i(shader, my_texture, 0)
    ShaderData_set_uniform_matrix4fv(shader, proj, projection)

    sprite_renderer_init(&state.sprite_renderer, state.resource_manager.shaders["basic_shader"])
    load_texture_into_resource_manager(&state.resource_manager, "assets/rock3.png", .RGBA, .ROCK3)
    
    current_time: f32

    // for dt
    // current_time: f32
    previous_time: f32 = f32(glfw.GetTime())

    // for frame count
    last_time := f32(glfw.GetTime())
    nb_frames: int

    for !glfw.WindowShouldClose(state.window_handle) {
        // Delta time
        current_time = f32(glfw.GetTime())
        dt = current_time - previous_time
        previous_time = current_time

        // frame count
        nb_frames += 1
        if current_time - last_time >= 1.0 {
            fmt.printf("[FPS]: %v\n", nb_frames)
            nb_frames = 0
            last_time += 1.0
        }

        // input
        custom_process_input(&state, f32(dt))

        // rendering
        custom_clear({0.5, 0.5, 0.5, 1.0})
        sprite_renderer_draw(state.sprite_renderer, get_texture_from_resource_manager(state.resource_manager, .ROCK3), {500.0, 500.0}, {1.0, 1.0}, 0.0, {0.0, 1.0, 0.0})

        // get the events and swap the front and back buffers
        glfw.PollEvents()
        glfw.SwapBuffers(state.window_handle)
    }

}


/* CALLBACKS functions. */

// Adapt the framebuffer.
window_framebuffer_size_callback :: proc "c" (window_handle: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}

// Continue to draw when resizing the window.
window_framebuffer_refresh_callback :: proc "c" (window_handle: glfw.WindowHandle) {
    // We define the context explicitly
    context = runtime.default_context()

    // custom_render need a context to work, since we're using a 'c' type proc.
    // custom_render(textured_model)
    custom_clear({1.0, 1.0, 1.0, 1.0})
    // gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, rawptr(uintptr(0)))
    glfw.SwapBuffers(window_handle)
}

mouse_input_callback :: proc "c" (window_handle: glfw.WindowHandle, mouse_x: f64, mouse_y: f64) {
    context = runtime.default_context()

    x_pos := mouse_x
    y_pos := mouse_y

    if first_mouse {
        last_x = x_pos
        last_y = y_pos
        first_mouse = false
    }

    x_offset: f32 = f32(x_pos) - f32(last_x)
    y_offset: f32 = f32(last_y) - f32(y_pos)

    last_x = x_pos
    last_y = y_pos

    Camera_process_mouse_input(&camera, &x_offset, &y_offset)

}

mouse_scroll_input_callback :: proc "c" (window_handle: glfw.WindowHandle, x_offset, y_offset: f64) {
    context = runtime.default_context()

    Camera_process_mouse_scroll(&camera, f32(y_offset))
}
