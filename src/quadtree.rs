use std::collections::HashMap;
use crate::models::rect::Rect;
use crate::models::quad::Quad;
use crate::geometry::{covers, intersects};

/// Recursively builds a quadtree over the grid, marking cells as Free, Blocked, or Split.
pub fn build_quad(obstacles: &[Rect], x: i32, y: i32, size: i32) -> Quad {
    if size <= 1 {
        for obs in obstacles {
            if intersects(obs, x, y, size) {
                return Quad::Blocked;
            }
        }
        return Quad::Free(x, y, size);
    }

    // If any obstacle fully covers this cell, it's entirely blocked
    if obstacles.iter().any(|obs| covers(obs, x, y, size)) {
        return Quad::Blocked;
    }

    // If no obstacle even touches this cell, it's entirely free
    if !obstacles.iter().any(|obs| intersects(obs, x, y, size)) {
        return Quad::Free(x, y, size);
    }

    // Otherwise split into 4 children: NW, NE, SW, SE
    let h = size / 2;
    let nw = build_quad(obstacles, x, y + h, h);
    let ne = build_quad(obstacles, x + h, y + h, h);
    let sw = build_quad(obstacles, x, y, h);
    let se = build_quad(obstacles, x + h, y, h);

    Quad::Split(Box::new([nw, ne, sw, se]))
}

/// Traverses the quadtree and collects the center coordinates of all free cells,
/// assigning each a unique id.
pub fn collect_free(quad: &Quad, id: &mut usize, map: &mut HashMap<usize, (f64, f64)>) {
    match quad {
        Quad::Free(x, y, s) => {
            let cx = *x as f64 + *s as f64 / 2.0;
            let cy = *y as f64 + *s as f64 / 2.0;
            map.insert(*id, (cx, cy));
            *id += 1;
        }
        Quad::Split(children) => {
            for child in children.iter() {
                collect_free(child, id, map);
            }
        }
        Quad::Blocked => {}
    }
}
