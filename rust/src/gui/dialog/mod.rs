use iced::{
    widget::{Button, Column, Container, Scrollable, Text, TextInput},
    Element, Renderer,
};
use iced_aw::{style::CardStyles, Card};
use loretex::errors::LoreTexError;

use super::app::{message_handling::GuiMessage, SqlGui};

#[derive(Clone)]
pub(crate) struct Dialog {
    dialog_type: DialogType,
    header: String,
}

impl SqlGui {
    pub(crate) fn update_dialog(&mut self, event: DialogMessage) {
        match event {
            DialogMessage::NewEntity(event) => match event {
                NewEntityMessage::LabelUpdated(str) => self.dialog = Some(Dialog::new_entity()),
                NewEntityMessage::TypeUpdated(str) => self.dialog = Some(Dialog::new_entity()),
                NewEntityMessage::Submit => self.dialog = None,
            },
        }
    }
}

impl Dialog {
    pub(crate) fn new_entity() -> Self {
        Dialog {
            dialog_type: DialogType::NewEntity {
                label: "".to_string(),
                ent_type: "".to_string(),
            },
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
            DialogType::NewEntity { label, ent_type } => self.new_entity_content(label, ent_type),
            DialogType::Error { error } => self.error_content(error),
        }
    }

    fn new_entity_content<'a>(&self, label: &String, ent_type: &String) -> Element<'a, GuiMessage> {
        let label_input = TextInput::new("", label).on_input(|str| {
            GuiMessage::DialogUpdated(DialogMessage::NewEntity(NewEntityMessage::LabelUpdated(
                str,
            )))
        });
        let type_input = TextInput::new("", &ent_type).on_input(|str| {
            GuiMessage::DialogUpdated(DialogMessage::NewEntity(NewEntityMessage::TypeUpdated(str)))
        });
        let submit_button = Button::new(Text::new("Create")).on_press(GuiMessage::DialogUpdated(
            DialogMessage::NewEntity(NewEntityMessage::Submit),
        ));
        Column::new()
            .push(Text::new("Label:"))
            .push(label_input)
            .push(Text::new("Type:"))
            .push(type_input)
            .push(submit_button)
            .padding(5)
            .spacing(5)
            .into()
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
    NewEntity { label: String, ent_type: String },
    Error { error: LoreTexError },
}

#[derive(Debug, Clone)]
pub(crate) enum DialogMessage {
    NewEntity(NewEntityMessage),
}

#[derive(Debug, Clone)]
pub(crate) enum NewEntityMessage {
    LabelUpdated(String),
    TypeUpdated(String),
    Submit,
}
