use self::{
    error::ErrorState,
    new_entity::{NewEntityMes, NewEntityState},
};
use super::app::{message_handling::GuiMes, SqlGui};
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

impl SqlGui {
    pub(crate) fn update_dialog(&mut self, event: DialogMes) {
        match event {
            DialogMes::NewEntity(event) => self.update_new_entity_dialog(event),
        }
    }
}

impl Dialog {
    fn content<'a>(&self) -> Element<'a, GuiMes> {
        match &self.dialog_type {
            DialogType::NewEntity(state) => self.new_entity_content(state),
            DialogType::Error(state) => self.error_content(state),
        }
    }
}

impl<'a> From<Dialog> for Element<'a, GuiMes> {
    fn from(dialog: Dialog) -> Self {
        let header: Text<'a, Renderer> = Text::new(dialog.header.clone());
        let content = dialog.content();
        let mut card =
            Card::new::<Element<'a, GuiMes>, Element<'a, GuiMes>>(header.into(), content.into())
                .on_close(GuiMes::DialogClosed);
        match dialog.dialog_type {
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
    NewEntity(NewEntityState),
    Error(ErrorState),
}

#[derive(Debug, Clone)]
pub(crate) enum DialogMes {
    NewEntity(NewEntityMes),
}
