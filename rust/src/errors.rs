#[derive(Debug, Clone)]
pub enum LoreTexError {
    FileError(String),
    InputError(String),
    SqlError(String),
}

impl ToString for LoreTexError {
    fn to_string(&self) -> String {
        format!("{:?}", self)
    }
}
