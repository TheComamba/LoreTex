use crate::{
    gui::{
        entity_view::{EntityView, EntityViewState},
        user_preferences::load_database_path,
    },
    APP_TITLE,
};

use super::{message_handling::GuiMessage, SqlGui};
use iced::{
    widget::{Button, Column, Container, Row, Scrollable, Text},
    Alignment, Length, Sandbox,
};
use iced_aw::{style::CardStyles, Card};
use iced_lazy::component;

impl Sandbox for SqlGui {
    type Message = GuiMessage;

    fn new() -> Self {
        let mut gui = SqlGui {
            entity_view_state: EntityViewState::new(),
            lore_database: None,
            error_message: None,
        };
        if let Some(path) = load_database_path() {
            gui.open_database(path);
        }
        gui
    }

    fn title(&self) -> String {
        APP_TITLE.to_string()
    }

    fn update(&mut self, message: Self::Message) {
        if let Err(e) = self.handle_message(message) {
            self.error_message = Some(e.to_string());
        }
    }

    fn view(&self) -> iced::Element<'_, Self::Message> {
        match self.error_message.clone() {
            None => Column::new()
                .push(self.menu_bar())
                .push(self.current_database_display())
                .push(component(EntityView::new(
                    &self.entity_view_state,
                    &self.lore_database,
                )))
                .into(),
            Some(message) => self.error_dialog(message),
        }
    }
}

impl SqlGui {
    fn menu_bar(&self) -> iced::Element<'_, GuiMessage> {
        Row::new()
            .push(Button::new("New Lore Database").on_press(GuiMessage::NewDatabase))
            .push(Button::new("Open Lore Database").on_press(GuiMessage::OpenDatabase))
            .align_items(Alignment::Center)
            .width(Length::Fill)
            .padding(5)
            .spacing(5)
            .into()
    }

    fn current_database_display(&self) -> iced::Element<'_, GuiMessage> {
        let content = match self.lore_database.as_ref() {
            Some(db) => db.path_as_string(),
            None => "[No database loaded]".to_string(),
        };
        Container::new(Text::new(content)).padding(5).into()
    }

    fn error_dialog(&self, text: String) -> iced::Element<'_, GuiMessage> {
        Container::new(Scrollable::new(
            Card::new(Text::new("Error"), Text::new(text))
                .style(CardStyles::Danger)
                .on_close(GuiMessage::ErrorDialogClosed),
        ))
        .padding(10)
        .into()
    }
}
