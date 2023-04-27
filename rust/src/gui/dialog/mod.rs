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
}

impl Dialog {
    pub(crate) fn new_entity() -> Self {
        Dialog {
            dialog_type: DialogType::NewEntity,
            header: "Create new Entity".to_string(),
        }
    }

    pub(crate) fn error(error: LoreTexError) -> Self {
        Dialog {
            dialog_type: DialogType::Error { error },
            header: "Error".to_string(),
        }
    }

    fn content<'a>(&self) -> Element<'a, GuiMessage> {
        match &self.dialog_type {
            DialogType::NewEntity => self.new_entity_content(),
            DialogType::Error { error } => self.error_content(error),
        }
    }

    fn new_entity_content<'a>(&self) -> Element<'a, GuiMessage> {
        Text::new("".to_string()).into()
    }

    fn error_content<'a>(&self, error: &LoreTexError) -> Element<'a, GuiMessage> {
        Text::new(error.to_string()).into()
    }
}

impl<'a> From<Dialog> for Element<'a, GuiMessage> {
    fn from(dialog: Dialog) -> Self {
        let header: Text<'a, Renderer> = Text::new(dialog.header.clone());
        let content = dialog.content();
        let mut card = Card::new::<Element<'a, GuiMessage>, Element<'a, GuiMessage>>(
            header.into(),
            content.into(),
        )
        .on_close(GuiMessage::DialogClosed);
        match dialog.dialog_type {
            DialogType::Error { error: _ } => {
                card = card.style(CardStyles::Danger);
            }
            _ => {
                card = card.style(CardStyles::Primary);
            }
        }
        Container::new(Scrollable::new(card)).padding(100).into()
    }
}

#[derive(Clone)]
pub(crate) enum DialogType {
    NewEntity,
    Error { error: LoreTexError },
}
