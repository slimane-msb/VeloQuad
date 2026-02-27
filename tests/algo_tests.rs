use veloquad::algo::dijkstra;

#[test]
fn test_direct_connection() {
    let mut graph = vec![vec![]; 2];
    graph[0].push((1, 3.0));
    graph[1].push((0, 3.0));

    let result = dijkstra(&graph, 0, 1);
    assert!((result.unwrap() - 3.0).abs() < 1e-9);
}

#[test]
fn test_no_path() {
    let graph = vec![vec![], vec![]];
    let result = dijkstra(&graph, 0, 1);
    assert!(result.is_none());
}

#[test]
fn test_start_equals_goal() {
    let graph = vec![vec![]];
    let result = dijkstra(&graph, 0, 0);
    assert!((result.unwrap() - 0.0).abs() < 1e-9);
}

#[test]
fn test_shortest_of_two_paths() {
    // 0 --(1.0)--> 1 --(1.0)--> 2
    // 0 --(5.0)--> 2
    let mut graph = vec![vec![]; 3];
    graph[0].push((1, 1.0));
    graph[1].push((0, 1.0));
    graph[1].push((2, 1.0));
    graph[2].push((1, 1.0));
    graph[0].push((2, 5.0));
    graph[2].push((0, 5.0));

    let result = dijkstra(&graph, 0, 2);
    assert!((result.unwrap() - 2.0).abs() < 1e-9);
}

#[test]
fn test_longer_chain() {
    // 0 -> 1 -> 2 -> 3, each edge weight 1.5
    let mut graph = vec![vec![]; 4];
    for i in 0..3 {
        graph[i].push((i + 1, 1.5));
        graph[i + 1].push((i, 1.5));
    }
    let result = dijkstra(&graph, 0, 3);
    assert!((result.unwrap() - 4.5).abs() < 1e-9);
}
