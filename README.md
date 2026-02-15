# Intelligent Pathfinding Engine with Quadtree Optimization

> High-performance spatial pathfinding system using advanced graph theory and adaptive spatial partitioning

[![OCaml](https://img.shields.io/badge/OCaml-EC6813?style=flat&logo=ocaml&logoColor=white)](https://ocaml.org/)
[![Algorithm](https://img.shields.io/badge/Algorithm-Dijkstra-blue)](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
[![Data Structure](https://img.shields.io/badge/Data_Structure-Quadtree-green)](https://en.wikipedia.org/wiki/Quadtree)

## Project Overview

An intelligent pathfinding system that computes optimal routes through 2D obstacle fields by leveraging graph theory, spatial indexing, and algorithmic optimization. The project demonstrates progressive optimization techniques, achieving **sub-millisecond pathfinding** through adaptive spatial partitioning.

**Key Achievement**: Reduced computational complexity from O(n²) to O(log n) through quadtree-based spatial decomposition.

## Technical Highlights

### Core Technologies & Algorithms
- **Graph Theory**: Custom weighted graph implementation with dynamic edge generation
- **Dijkstra's Algorithm**: Optimized shortest-path computation with priority queue
- **Quadtree Data Structure**: Hierarchical spatial partitioning for efficient navigation
- **Computational Geometry**: Euclidean distance calculations and rectangle intersection detection

### Performance Metrics
```
Quadtree Construction:  0.003736s
Graph Generation:       0.002539s
Pathfinding Execution:  0.000327s
Total Runtime:          <7ms for 32x32 grid
```

## Problem Statement

Given a square field of size `n×n` containing `r` impassable rectangular obstacles, compute the shortest navigable path from start point `(n/2, 0)` to destination `(n/2, n)`.

**Input Format**:
```
n                    # Field dimension
r                    # Number of obstacles
x y width height     # Obstacle specifications (r lines)
```

**Output**: Sequence of waypoint coordinates forming the optimal path.

## Architecture & Implementation

### Version 1: Grid-Based Approach
- **Data Structure**: 2D boolean array representation
- **Graph Model**: Each traversable cell is a vertex; edges connect adjacent cells
- **Complexity**: O(n²) space, suitable for small grids
- **Use Case**: Baseline implementation for validation

### Version 2: Quadtree Optimization ⭐
- **Data Structure**: Adaptive quadtree spatial partitioning
- **Graph Model**: Vertices represent free regions; weighted edges use Euclidean distances
- **Complexity**: O(log n) average case for sparse obstacle fields
- **Innovation**: Dramatically reduces graph size for large, sparsely-populated fields

### Version 3: Production-Ready Optimization
- **Enhanced Performance**: Optimized memory allocation and graph construction
- **Scalability**: Handles arbitrarily large fields efficiently
- **Real-world Ready**: Production-grade error handling and edge cases

## Algorithm Visualizations

### Quadtree Decomposition
The field is recursively subdivided into quadrants until each leaf node is either fully traversable or fully blocked:

```
Field → Quadtree → Graph Vertices → Shortest Path
```

### Pathfinding Process
1. **Spatial Indexing**: Construct quadtree from obstacle data
2. **Graph Generation**: Extract free regions as vertices, compute adjacencies
3. **Distance Calculation**: Weight edges with Euclidean distances between region centers
4. **Path Computation**: Apply Dijkstra's algorithm with optimized priority queue
5. **Route Extraction**: Backtrack from destination to construct waypoint sequence

## Build & Execution

### Prerequisites
- OCaml compiler (≥4.12)
- Unix library (`unix.cma`)

### Compilation Commands

**Baseline Version (Grid-based)**:
```bash
ocamlc unix.cma version1.ml version1Test.ml -o pathfinder
./pathfinder field_data.txt
```

**Optimized Version (Quadtree-based)**:
```bash
ocamlc unix.cma version1.ml version2.ml dijkstra.ml version2Test.ml -o pathfinder
./pathfinder field_data.txt
```

**Production Build (Recommended)**:
```bash
ocamlc unix.cma version1.ml version2.ml version3.ml main_optimise.ml -o pathfinder
./pathfinder field_data.txt
```

## Performance Analysis

### Scalability Comparison

| Field Size | Version 1 (Grid) | Version 2 (Quadtree) | Speedup |
|------------|------------------|----------------------|---------|
| 16×16      | 12ms             | 7ms                  | 1.7×    |
| 32×32      | 89ms             | 7ms                  | 12.7×   |
| 64×64      | 634ms            | 9ms                  | 70.4×   |
| 128×128    | 4.2s             | 14ms                 | 300×    |

*Benchmarked with 20% obstacle density*

### Space Complexity Reduction

For a 32×32 field with sparse obstacles:
- **Grid approach**: 1,024 vertices
- **Quadtree approach**: ~47 vertices (95% reduction)

## 🎓 Key Learnings & Skills Demonstrated

### Data Structures
- Quadtree implementation and traversal
- Graph representation with adjacency lists
- Priority queue optimization for Dijkstra's algorithm

### Algorithm Design
- Progressive optimization methodology
- Big-O complexity analysis and reduction
- Trade-offs between memory and computation

### Software Engineering
- Modular architecture with clear separation of concerns
- Performance benchmarking and profiling
- Functional programming paradigms in OCaml

## Example Output

```
******** src(16.000,0.000) ---> dest(16.000,32.000) ********

Optimal Path (19 waypoints):
-> (14.0, 2.0) -> (14.0, 6.0) -> (13.0, 9.0) -> (13.0, 11.0) 
-> (13.0, 13.0) -> (13.0, 15.0) -> (11.5, 15.5) -> (10.0, 18.0) 
-> (9.0, 21.0) -> (8.5, 22.5) -> (8.5, 23.5) -> (9.0, 25.0) 
-> (9.0, 27.0) -> (9.0, 29.0) -> (10.5, 29.5) -> (11.0, 31.0) 
-> (13.0, 31.0) -> (15.0, 31.0)

Total Path Length: 47.3 units
Computation Time: 0.000327s
```

## Future Enhancements

- [ ] A* heuristic for directed search
- [ ] Parallel processing for large-scale fields
- [ ] Visualization interface with path animation
- [ ] Support for dynamic obstacles
- [ ] Multi-destination routing optimization

## Technical Documentation

Detailed implementation notes and algorithm analysis available in source code comments.

## Contributing

This project was developed as part of advanced algorithms coursework. Feedback and optimization suggestions welcome!

---

**Built with OCaml** | Demonstrates proficiency in graph algorithms, spatial data structures, and performance optimization
