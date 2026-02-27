use std::fs;
use crate::models::rect::Rect;

pub fn read_input(path: &str) -> (i32, Vec<Rect>) {
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
        obstacles.push(Rect {
            x: nums[0],
            y: nums[1],
            w: nums[2],
            h: nums[3],
        });
    }

    (n, obstacles)
}
