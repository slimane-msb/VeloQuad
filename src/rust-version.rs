use std::collections::{BinaryHeap, HashMap};
use std::cmp::Ordering;
use std::fs;

#[derive(Clone, Debug)]
enum Quad {
    Free(i32, i32, i32),  // x, y, size
    Blocked,
    Split(Box<[Quad; 4]>),
}

#[derive(Clone, Copy)]
struct Rect {
    x: i32,
    y: i32,
    w: i32,
    h: i32,
}

fn read_input(path: &str) -> (i32, Vec<Rect>) {
    let content = fs::read_to_string(path).unwrap();
    let lines: Vec<&str> = content.lines().collect();
    
    let n: i32 = lines[0].trim().parse().unwrap();
    let r: usize = lines[1].trim().parse().unwrap();
    
    let mut obstacles = Vec::new();
    for i in 0..r {
        let nums: Vec<i32> = lines[i + 2]
            .split_whitespace()
            .map(|s| s.parse().unwrap())
            .collect();
        obstacles.push(Rect { x: nums[0], y: nums[1], w: nums[2], h: nums[3] });
    }
    
    (n, obstacles)
}

fn intersects(rect: &Rect, qx: i32, qy: i32, qs: i32) -> bool {
    !(rect.x >= qx + qs || rect.x + rect.w <= qx ||
      rect.y >= qy + qs || rect.y + rect.h <= qy)
}

fn covers(rect: &Rect, qx: i32, qy: i32, qs: i32) -> bool {
    rect.x <= qx && rect.x + rect.w >= qx + qs &&
    rect.y <= qy && rect.y + rect.h >= qy + qs
}

fn build_quad(obstacles: &[Rect], x: i32, y: i32, size: i32) -> Quad {
    if size <= 1 {
        for obs in obstacles {
            if intersects(obs, x, y, size) {
                return Quad::Blocked;
            }
        }
        return Quad::Free(x, y, size);
    }
    
    let blocked = obstacles.iter().any(|obs| covers(obs, x, y, size));
    if blocked {
        return Quad::Blocked;
    }
    
    let has_obstacle = obstacles.iter().any(|obs| intersects(obs, x, y, size));
    if !has_obstacle {
        return Quad::Free(x, y, size);
    }
    
    let h = size / 2;
    let nw = build_quad(obstacles, x, y + h, h);
    let ne = build_quad(obstacles, x + h, y + h, h);
    let sw = build_quad(obstacles, x, y, h);
    let se = build_quad(obstacles, x + h, y, h);
    
    Quad::Split(Box::new([nw, ne, sw, se]))
}

fn collect_free(quad: &Quad, id: &mut usize, map: &mut HashMap<usize, (f64, f64)>) {
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

fn build_graph(quad: &Quad, id: &mut usize, graph: &mut Vec<Vec<(usize, f64)>>, centers: &HashMap<usize, (f64, f64)>) -> Vec<usize> {
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

#[derive(Copy, Clone, PartialEq)]
struct State {
    cost: f64,
    node: usize,
}

impl Eq for State {}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other.cost.partial_cmp(&self.cost).unwrap_or(Ordering::Equal)
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn dijkstra(graph: &[Vec<(usize, f64)>], start: usize, goal: usize) -> Option<f64> {
    let mut dist = vec![f64::INFINITY; graph.len()];
    dist[start] = 0.0;
    
    let mut heap = BinaryHeap::new();
    heap.push(State { cost: 0.0, node: start });
    
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
                heap.push(State { cost: next, node: neighbor });
            }
        }
    }
    
    None
}

fn find_nearest(x: i32, y: i32, centers: &HashMap<usize, (f64, f64)>) -> usize {
    centers.iter()
        .min_by(|(_, (cx1, cy1)), (_, (cx2, cy2))| {
            let d1 = (x as f64 - cx1).powi(2) + (y as f64 - cy1).powi(2);
            let d2 = (x as f64 - cx2).powi(2) + (y as f64 - cy2).powi(2);
            d1.partial_cmp(&d2).unwrap()
        })
        .map(|(id, _)| *id)
        .unwrap()
}

fn main() {
    let (n, obstacles) = read_input("./src/tree.txt");
    
    println!("Grille: {}x{}, Obstacles: {}", n, n, obstacles.len());
    
    let quad = build_quad(&obstacles, 0, 0, n);
    
    let mut centers = HashMap::new();
    let mut id = 0;
    collect_free(&quad, &mut id, &mut centers);
    
    println!("Régions libres: {}", centers.len());
    
    let mut graph = vec![vec![]; centers.len()];
    let mut id = 0;
    build_graph(&quad, &mut id, &mut graph, &centers);
    
    let start = find_nearest(n / 2, 0, &centers);
    let goal = find_nearest(n / 2, n - 1, &centers);
    
    match dijkstra(&graph, start, goal) {
        Some(dist) => println!("Distance trouvée: {:.2}", dist),
        None => println!("Pas de chemin!"),
    }
}
