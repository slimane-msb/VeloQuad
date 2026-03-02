mod algo;
mod geometry;
mod graph;
mod input;
mod models;
mod quadtree;

use std::collections::HashMap;
use std::env;

use algo::dijkstra;
use graph::{build_graph, find_nearest};
use input::read_input;
use quadtree::{build_quad, collect_free};

fn main() {
    let mut args = env::args().skip(1); 

    // Handle optional -f
    let first = args.next().expect("Missing file path");
    let file_path = if first == "-f" {
        args.next().expect("Missing file path after -f")
    } else {
        first
    };

    // Default coordinates
    let mut sx = 0;
    let mut sy = 0;
    let mut gx = 7;
    let mut gy = 7;

    // If 4 extra args exist, override defaults
    if let (Some(a), Some(b), Some(c), Some(d)) =
        (args.next(), args.next(), args.next(), args.next())
    {
        sx = a.parse().expect("Invalid start x");
        sy = b.parse().expect("Invalid start y");
        gx = c.parse().expect("Invalid goal x");
        gy = d.parse().expect("Invalid goal y");
    }

    let (n, obstacles) = read_input(&file_path);

    println!("Grille: {}x{}, Obstacles: {}", n, n, obstacles.len());

    let quad = build_quad(&obstacles, 0, 0, n);

    let mut centers: HashMap<usize, (f64, f64)> = HashMap::new();
    let mut id = 0;
    collect_free(&quad, &mut id, &mut centers);

    println!("Régions libres: {}", centers.len());

    let mut graph = vec![vec![]; centers.len()];
    let mut id = 0;
    build_graph(&quad, &mut id, &mut graph, &centers);

    let start = find_nearest(sx, sy, &centers);
    let goal = find_nearest(gx, gy, &centers);

    match dijkstra(&graph, start, goal) {
        Some(dist) => println!("Distance trouvée: {:.2}", dist),
        None => println!("Pas de chemin!"),
    }
}