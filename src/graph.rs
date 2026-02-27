use std::collections::HashMap;
use crate::models::quad::Quad;

/// Recursively traverses the quadtree and builds an adjacency list graph.
/// Sibling free cells within the same Split node are connected by Euclidean distance.
/// Returns the list of node ids belonging to the subtree rooted at `quad`.
pub fn build_graph(
    quad: &Quad,
    id: &mut usize,
    graph: &mut Vec<Vec<(usize, f64)>>,
    centers: &HashMap<usize, (f64, f64)>,
) -> Vec<usize> {
    match quad {
        Quad::Free(_, _, _) => {
            let current = *id;
            *id += 1;
            vec![current]
        }
        Quad::Split(children) => {
            let mut ids = Vec::new();
            for child in children.iter() {
                ids.extend(build_graph(child, id, graph, centers));
            }

            // Connect every pair of free siblings
            for i in 0..ids.len() {
                for j in i + 1..ids.len() {
                    let id1 = ids[i];
                    let id2 = ids[j];
                    let (x1, y1) = centers[&id1];
                    let (x2, y2) = centers[&id2];
                    let dist = ((x2 - x1).powi(2) + (y2 - y1).powi(2)).sqrt();

                    graph[id1].push((id2, dist));
                    graph[id2].push((id1, dist));
                }
            }
            ids
        }
        Quad::Blocked => vec![],
    }
}

/// Returns the id of the free cell whose center is nearest to the point (x, y).
pub fn find_nearest(x: i32, y: i32, centers: &HashMap<usize, (f64, f64)>) -> usize {
    centers
        .iter()
        .min_by(|(_, (cx1, cy1)), (_, (cx2, cy2))| {
            let d1 = (x as f64 - cx1).powi(2) + (y as f64 - cy1).powi(2);
            let d2 = (x as f64 - cx2).powi(2) + (y as f64 - cy2).powi(2);
            d1.partial_cmp(&d2).unwrap()
        })
        .map(|(id, _)| *id)
        .unwrap()
}
