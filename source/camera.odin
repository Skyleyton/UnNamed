package main

import "core:math"
import "core:math/linalg"

CameraDirection :: enum {
    LEFT,
    RIGHT,
    UP,
    DOWN
}

// Default cam values
YAW: f32 : -90.0
PITCH: f32 : 0.0
SPEED: f32 : 2.0
SENSITIVITY: f32 : 0.05
ZOOM: f32 : 45.0

Camera :: struct {
    // Attributs de la camera
    position: linalg.Vector3f32,
    front: linalg.Vector3f32, // La face avant de la caméra
    up: linalg.Vector3f32, // La face haute de la caméra
    right: linalg.Vector3f32, // La face droite de la caméra
    world_up: linalg.Vector3f32,

    // Angles d'Eulers
    yaw: f32,
    pitch: f32,

    // Options de la camera.
    movement_speed: f32,
    mouse_sensitivity: f32,
    zoom: f32,
}

// Retourne une caméra.
Camera_new :: proc(position:=linalg.Vector3f32{0.0, 0.0, 0.0}, up:=linalg.Vector3f32{0.0, 1.0, 0.0}, yaw:=YAW, pitch:=PITCH, movement_speed:=SPEED, mouse_sensitivity:=SENSITIVITY, zoom:=ZOOM) -> Camera {
    camera := Camera{
        position = position,
        world_up = up,
        yaw = yaw,
        pitch = pitch,
        movement_speed = movement_speed,
        mouse_sensitivity = mouse_sensitivity,
        zoom = zoom,
    }

    Camera_update_vectors(&camera)
    return camera
}

// Retourne la view matrix.
Camera_get_view_matrix :: proc(camera: Camera) -> linalg.Matrix4f32 {
    return linalg.matrix4_look_at_f32(camera.position, camera.position + camera.front, camera.up)
}

// Traite les inputs du clavier
Camera_process_keyboard_input :: proc(camera: ^Camera, cam_direction: CameraDirection, delta_time: f32) {
    velocity: f32 = camera.movement_speed * delta_time

    switch cam_direction {
        case .FORWARD:
            camera.position += camera.front * velocity
        case .BACKWARD:
            camera.position -= camera.front * velocity
        case .LEFT:
            camera.position -= camera.right * velocity
        case .RIGHT:
            camera.position += camera.right * velocity
        case .UP:
            camera.position.y += velocity
        case .DOWN:
            camera.position.y -= velocity
    }
}

// Met à jour les vecteurs de la camera.
Camera_update_vectors :: proc(camera: ^Camera) {
    front: linalg.Vector3f32

    front[0] = math.cos(linalg.to_radians(camera.yaw)) * math.cos(linalg.to_radians(camera.pitch))
    front[1] = math.sin(linalg.to_radians(camera.pitch))
    front[2] = math.sin(linalg.to_radians(camera.yaw)) * math.cos(linalg.to_radians(camera.pitch))

    camera.front = linalg.normalize(front)
    camera.right = linalg.normalize(linalg.vector_cross3(camera.front, camera.world_up))
    camera.up = linalg.normalize(linalg.vector_cross3(camera.right, camera.front))
}

// Traite les mouvements de la souris.
Camera_process_mouse_input :: proc(camera: ^Camera, x_offset, y_offset: ^f32, should_block_pitch:bool=true) {
    x_offset^ *= camera.mouse_sensitivity
    y_offset^ *= camera.mouse_sensitivity

    camera.yaw += x_offset^
    camera.pitch += y_offset^

    if should_block_pitch {
        if camera.pitch > 89.0 {
            camera.pitch = 89.0
        }
        if camera.pitch < -89.0 {
            camera.pitch = -89.0
        }
    }

    Camera_update_vectors(camera)
}

// Traite le scroll de la souris.
Camera_process_mouse_scroll :: proc(camera: ^Camera, y_offset: f32) {
    camera.zoom -= y_offset
    if camera.zoom < 1.0 {
        camera.zoom = 1.0
    }
    if camera.zoom > 45.0 {
        camera.zoom = 45.0
    }
}
