use veloquad::models::rect::Rect;
use veloquad::quadtree::{build_quad, collect_free};
use veloquad::graph::{build_graph, find_nearest};
use std::collections::HashMap;

#[test]
fn test_find_nearest_basic() {
    let mut centers = HashMap::new();
    centers.insert(0, (1.0, 1.0));
    centers.insert(1, (5.0, 5.0));

    let nearest = find_nearest(0, 0, &centers);
    assert_eq!(nearest, 0);
}

#[test]
fn test_graph_nodes_connected() {
    // Grid with a partial obstacle: two free siblings should be connected
    let obs = vec![Rect { x: 0, y: 0, w: 2, h: 2 }];
    let quad = build_quad(&obs, 0, 0, 4);

    let mut centers = HashMap::new();
    let mut id = 0;
    collect_free(&quad, &mut id, &mut centers);

    let mut graph = vec![vec![]; centers.len()];
    let mut id = 0;
    build_graph(&quad, &mut id, &mut graph, &centers);

    // At least one node should have edges (siblings connected)
    let has_edges = graph.iter().any(|neighbors| !neighbors.is_empty());
    assert!(has_edges);
}

#[test]
fn test_empty_grid_single_node_no_edges() {
    let quad = build_quad(&[], 0, 0, 4);

    let mut centers = HashMap::new();
    let mut id = 0;
    collect_free(&quad, &mut id, &mut centers);

    let mut graph = vec![vec![]; centers.len()];
    let mut id = 0;
    build_graph(&quad, &mut id, &mut graph, &centers);

    // Single free cell → no edges
    assert_eq!(graph.len(), 1);
    assert!(graph[0].is_empty());
}
