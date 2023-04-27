use super::{Dialog, DialogType};
use crate::gui::app::message_handling::GuiMes;
use iced::{widget::Text, Element};
use loretex::errors::LoreTexError;

impl Dialog {
    pub(crate) fn error(error: LoreTexError) -> Self {
        Dialog {
            dialog_type: DialogType::Error { error },
            header: "Error".to_string(),
        }
    }

    pub(super) fn error_content<'a>(&self, error: &LoreTexError) -> Element<'a, GuiMes> {
        Text::new(error.to_string()).into()
    }
}
