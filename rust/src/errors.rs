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

pub(super) fn sql_loading_error_message<E>(
    loadee: &str,
    target: &str,
    params: Vec<(&str, &Option<String>)>,
    err: E,
) -> String
where
    E: ToString,
{
    let mut string = "Loading ".to_string() + loadee + " to get " + target;
    let mut is_any_param_printed = false;
    for (name, value) in params {
        if let Some(value) = value {
            if !is_any_param_printed {
                string += " for parameters ";
                is_any_param_printed = true;
            } else {
                string += ", "
            }
            string += name;
            string += "='";
            string += value;
            string += "'";
        }
    }
    string += " failed: ";
    string += &err.to_string();
    string
}
