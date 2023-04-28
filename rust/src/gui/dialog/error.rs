use super::{Dialog, DialogType};
use crate::gui::app::message_handling::GuiMes;
use iced::{widget::Text, Element};
use loretex::errors::LoreTexError;

impl Dialog {
    pub(crate) fn error(error: LoreTexError) -> Self {
        Dialog {
            dialog_type: DialogType::Error(ErrorState { error }),
            header: "Error".to_string(),
        }
    }

    pub(super) fn error_content<'a>(&self, state: &ErrorState) -> Element<'a, GuiMes> {
        Text::new(state.error.to_string()).into()
    }
}

#[derive(Debug, Clone)]
pub(crate) struct ErrorState {
    error: LoreTexError,
}
