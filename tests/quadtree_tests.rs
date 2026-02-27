use veloquad::models::rect::Rect;
use veloquad::models::quad::Quad;
use veloquad::quadtree::{build_quad, collect_free};
use std::collections::HashMap;

#[test]
fn test_empty_grid_is_free() {
    let quad = build_quad(&[], 0, 0, 4);
    matches!(quad, Quad::Free(_, _, _));
}

#[test]
fn test_fully_blocked_cell() {
    let obs = vec![Rect { x: 0, y: 0, w: 4, h: 4 }];
    let quad = build_quad(&obs, 0, 0, 4);
    assert!(matches!(quad, Quad::Blocked));
}

#[test]
fn test_partial_obstacle_splits() {
    let obs = vec![Rect { x: 0, y: 0, w: 2, h: 2 }];
    let quad = build_quad(&obs, 0, 0, 4);
    assert!(matches!(quad, Quad::Split(_)));
}

#[test]
fn test_collect_free_counts() {
    let quad = build_quad(&[], 0, 0, 4);
    let mut centers = HashMap::new();
    let mut id = 0;
    collect_free(&quad, &mut id, &mut centers);
    assert_eq!(centers.len(), 1);
}

#[test]
fn test_collect_free_center_position() {
    let quad = build_quad(&[], 0, 0, 4);
    let mut centers = HashMap::new();
    let mut id = 0;
    collect_free(&quad, &mut id, &mut centers);
    let (cx, cy) = centers[&0];
    assert!((cx - 2.0).abs() < 1e-9);
    assert!((cy - 2.0).abs() < 1e-9);
}
