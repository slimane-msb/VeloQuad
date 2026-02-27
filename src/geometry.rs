use crate::models::rect::Rect;

/// Returns true if the rectangle intersects the quadtree cell at (qx, qy) with side `qs`.
pub fn intersects(rect: &Rect, qx: i32, qy: i32, qs: i32) -> bool {
    !(rect.x >= qx + qs
        || rect.x + rect.w <= qx
        || rect.y >= qy + qs
        || rect.y + rect.h <= qy)
}

/// Returns true if the rectangle fully covers the quadtree cell at (qx, qy) with side `qs`.
pub fn covers(rect: &Rect, qx: i32, qy: i32, qs: i32) -> bool {
    rect.x <= qx
        && rect.x + rect.w >= qx + qs
        && rect.y <= qy
        && rect.y + rect.h >= qy + qs
}
