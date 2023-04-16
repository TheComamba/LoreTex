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

pub(super) fn sql_loading_error_message_no_params<E>(loadee: &str, target: &str, err: E) -> String
where
    E: ToString,
{
    sql_loading_error_message::<String, E>(loadee, target, vec![], err)
}

pub(super) fn sql_loading_error_message<T, E>(
    loadee: &str,
    target: &str,
    params: Vec<(&str, &Option<T>)>,
    err: E,
) -> String
where
    T: ToString,
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
            string += &value.to_string();
            string += "'";
        }
    }
    string += " failed: ";
    string += &err.to_string();
    string
}
