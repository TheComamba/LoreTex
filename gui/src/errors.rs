#[derive(Debug, Clone)]
pub(crate) enum GuiError {
    Other(String),
}

impl ToString for GuiError {
    fn to_string(&self) -> String {
        return format!("{:?}", self);
    }
}
