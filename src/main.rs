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
    let args: Vec<String> = env::args().collect();
    let file_path = match args.len() {
        2 => &args[1],
        3 if args[1] == "-f" => &args[2],
        _ => {
            eprintln!("Usage: {} [-f] <file_path>", args[0]);
            std::process::exit(1);
        }
    };
    let (n, obstacles) = read_input(file_path);

    println!("Grille: {}x{}, Obstacles: {}", n, n, obstacles.len());

    let quad = build_quad(&obstacles, 0, 0, n);

    let mut centers: HashMap<usize, (f64, f64)> = HashMap::new();
    let mut id: usize = 0;
    collect_free(&quad, &mut id, &mut centers);

    println!("Régions libres: {}", centers.len());

    let mut graph = vec![vec![]; centers.len()];
    let mut id: usize = 0;
    build_graph(&quad, &mut id, &mut graph, &centers);

    let start = find_nearest(n / 2, 0, &centers);
    let goal = find_nearest(n / 2, n - 1, &centers);

    match dijkstra(&graph, start, goal) {
        Some(dist) => println!("Distance trouvée: {:.2}", dist),
        None => println!("Pas de chemin!"),
    }
}