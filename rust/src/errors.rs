#[derive(Debug, Clone)]
pub enum LoreTexError {
    SqlError(String),
    FileError(String),
}

impl ToString for LoreTexError {
    fn to_string(&self) -> String {
        format!("{:?}", self)
    }
}
