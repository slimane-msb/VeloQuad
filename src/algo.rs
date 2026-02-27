use std::collections::BinaryHeap;
use crate::models::state::State;

/// Runs Dijkstra's algorithm on the adjacency list `graph` from `start` to `goal`.
/// Returns the shortest distance, or `None` if no path exists.
pub fn dijkstra(graph: &[Vec<(usize, f64)>], start: usize, goal: usize) -> Option<f64> {
    let mut dist = vec![f64::INFINITY; graph.len()];
    dist[start] = 0.0;

    let mut heap = BinaryHeap::new();
    heap.push(State {
        cost: 0.0,
        node: start,
    });

    while let Some(State { cost, node }) = heap.pop() {
        if node == goal {
            return Some(cost);
        }

        if cost > dist[node] {
            continue;
        }

        for &(neighbor, weight) in &graph[node] {
            let next = cost + weight;
            if next < dist[neighbor] {
                dist[neighbor] = next;
                heap.push(State {
                    cost: next,
                    node: neighbor,
                });
            }
        }
    }

    None
}
