use iced::{
    widget::{Container, Scrollable, Text},
    Element,
};
use iced_aw::{style::CardStyles, Card};
use loretex::errors::LoreTexError;

use super::app::message_handling::GuiMessage;

#[derive(Clone)]
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

impl From<Dialog> for Element<'_, GuiMessage> {
    fn from(dialog: Dialog) -> Self {
        let card = Card::new(Text::new(dialog.header), Text::new(dialog.content))
            .style(CardStyles::Danger)
            .on_close(GuiMessage::DialogClosed);
        Container::new(Scrollable::new(card)).padding(100).into()
    }
}

#[derive(Clone)]
pub(crate) enum DialogType {
    Error,
}
