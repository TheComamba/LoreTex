use iced::{
    widget::{Container, Scrollable, Text},
    Element, Renderer,
};
use iced_aw::{style::CardStyles, Card};
use loretex::errors::LoreTexError;

use super::app::message_handling::GuiMessage;

#[derive(Clone)]
pub(crate) struct Dialog {
    dialog_type: DialogType,
    header: String,
    text: String,
}

impl Dialog {
    pub(crate) fn error(error: LoreTexError) -> Self {
        Dialog {
            dialog_type: DialogType::Error,
            header: "Error".to_string(),
            text: error.to_string(),
        }
    }

    fn content<'a>(self) -> Element<'a, GuiMessage> {
        match self.dialog_type {
            DialogType::Error => self.error_content(),
        }
    }

    fn error_content<'a>(self) -> Element<'a, GuiMessage> {
        Text::new(self.text.clone()).into()
    }
}

impl<'a> From<Dialog> for Element<'a, GuiMessage> {
    fn from(dialog: Dialog) -> Self {
        let header: Text<'a, Renderer> = Text::new(dialog.header.clone());
        let content = dialog.content();
        let card = Card::new::<Element<'a, GuiMessage>, Element<'a, GuiMessage>>(
            header.into(),
            content.into(),
        )
        .style(CardStyles::Danger)
        .on_close(GuiMessage::DialogClosed);
        Container::new(Scrollable::new(card)).padding(100).into()
    }
}

#[derive(Clone)]
pub(crate) enum DialogType {
    Error,
}
