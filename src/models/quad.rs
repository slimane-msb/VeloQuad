#[derive(Clone, Debug)]
pub enum Quad {
    Free(i32, i32, i32), // x, y, size
    Blocked,
    Split(Box<[Quad; 4]>),
}
