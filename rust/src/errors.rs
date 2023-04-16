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

pub(super) fn sql_loading_error_no_params<E>(loadee: &str, target: &str, err: E) -> LoreTexError
where
    E: ToString,
{
    sql_loading_error::<String, E>(loadee, target, vec![], err)
}

pub(super) fn sql_loading_error<T, E>(
    loadee: &str,
    target: &str,
    params: Vec<(&str, &Option<T>)>,
    err: E,
) -> LoreTexError
where
    T: ToString,
    E: ToString,
{
    let mut message = "Loading ".to_string() + loadee + " to get " + target;
    let mut is_any_param_printed = false;
    for (name, value) in params {
        if let Some(value) = value {
            if !is_any_param_printed {
                message += " for parameters ";
                is_any_param_printed = true;
            } else {
                message += ", "
            }
            message += name;
            message += "='";
            message += &value.to_string();
            message += "'";
        }
    }
    message += " failed: ";
    message += &err.to_string();
    LoreTexError::SqlError(message)
}
