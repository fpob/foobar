#![doc = include_str!("../README.md")]

fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_foobar() {
        assert!(true);
    }
}
