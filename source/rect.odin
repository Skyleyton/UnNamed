package main

// The true position of dimensions is position.x + dimensions.x and position.y + dimensions.y
Rectangle :: struct {
    position: [2]f32, // x and y
    dimensions: [2]f32 // width and height
}

rect_contains :: proc(rect: Rectangle, point: [2]f32) -> bool {
    return (rect.position.x <= point.x) && (rect.position.y <= point.y) &&
    (rect.position.x + rect.dimensions.x >= point.x) && (rect.position.y + rect.dimensions.y >= point.y) 
}