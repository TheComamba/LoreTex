use self::{error::ErrorDialog, new_entity::NewEntityDialog};
use super::app::message_handling::GuiMes;
use iced::{
    widget::{Container, Scrollable, Text},
    Element, Renderer,
};
use iced_aw::{style::CardStyles, Card};

mod error;
mod new_entity;

#[derive(Clone)]
pub(crate) struct Dialog {
    dialog_type: DialogType,
    header: String,
}

impl Dialog {
    fn body<'a>(self) -> Element<'a, GuiMes> {
        match self.dialog_type {
            DialogType::NewEntity(dialog) => dialog.into(),
            DialogType::Error(dialog) => dialog.into(),
        }
    }
}

impl<'a> From<Dialog> for Element<'a, GuiMes> {
    fn from(dialog: Dialog) -> Self {
        let header: Text<'a, Renderer> = Text::new(dialog.header.clone());
        let dialog_type = dialog.dialog_type.clone();
        let body = dialog.body();
        let mut card =
            Card::new::<Element<'a, GuiMes>, Element<'a, GuiMes>>(header.into(), body.into())
                .on_close(GuiMes::DialogClosed);
        match dialog_type {
            DialogType::Error(_) => {
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
    NewEntity(NewEntityDialog),
    Error(ErrorDialog),
}
