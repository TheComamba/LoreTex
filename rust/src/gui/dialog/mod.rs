use loretex::errors::LoreTexError;

pub(crate) struct Dialog {
    dialog_type: DialogType,
    header: String,
    content: String,
}

impl Dialog {
    pub(crate) fn error(error: LoreTexError) -> Self {
        Dialog {
            dialog_type: DialogType::Error,
            header: "Error".to_string(),
            content: error.to_string(),
        }
    }
}

pub(crate) enum DialogType {
    Error,
}
