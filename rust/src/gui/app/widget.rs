use crate::{
    gui::{
        entity_view::{EntityView, EntityViewState},
        history_view::HistoryView,
        relationship_view::RelationshipView,
        user_preferences::load_database_path,
    },
    APP_TITLE,
};

use super::{message_handling::GuiMessage, SqlGui, ViewType};
use iced::{
    widget::{button, Button, Column, Container, Row, Scrollable, Text},
    Alignment, Element, Length, Sandbox,
};
use iced_aw::{style::CardStyles, Card};

impl Sandbox for SqlGui {
    type Message = GuiMessage;

    fn new() -> Self {
        let mut gui = SqlGui {
            selected_view: super::ViewType::Entity,
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
        match self.error_message.as_ref() {
            Some(message) => self.error_dialog(message),
            None => self.main_view(),
        }
    }
}

impl SqlGui {
    fn main_view(&self) -> Element<'_, GuiMessage> {
        let mut col = Column::new()
            .push(self.menu_bar())
            .push(self.current_database_display())
            .push(self.view_selection_bar());
        match self.selected_view {
            ViewType::Entity => {
                col = col.push(EntityView::new(
                    &self.entity_view_state,
                    &self.lore_database,
                ))
            }
            ViewType::History => col = col.push(HistoryView::new()),
            ViewType::Relationship => col = col.push(RelationshipView::new()),
        }
        col.into()
    }

    fn menu_bar(&self) -> Element<'_, GuiMessage> {
        Row::new()
            .push(Button::new("New Lore Database").on_press(GuiMessage::NewDatabase))
            .push(Button::new("Open Lore Database").on_press(GuiMessage::OpenDatabase))
            .align_items(Alignment::Center)
            .width(Length::Fill)
            .padding(5)
            .spacing(5)
            .into()
    }

    fn current_database_display(&self) -> Element<'_, GuiMessage> {
        let content = match self.lore_database.as_ref() {
            Some(db) => db.path_as_string(),
            None => "[No database loaded]".to_string(),
        };
        Container::new(Text::new(content)).padding(5).into()
    }

    fn view_selection_bar(&self) -> Element<'_, GuiMessage> {
        let entity_button =
            button(Text::new("Entities")).on_press(GuiMessage::ViewSelected(ViewType::Entity));
        let history_items_button = button(Text::new("History Items"))
            .on_press(GuiMessage::ViewSelected(ViewType::History));
        let relationships_button = button(Text::new("Relationships"))
            .on_press(GuiMessage::ViewSelected(ViewType::Relationship));
        Row::new()
            .push(entity_button)
            .push(history_items_button)
            .push(relationships_button)
            .width(Length::Fill)
            .padding(5)
            .spacing(5)
            .into()
    }

    fn error_dialog<'a>(&self, text: &'a String) -> Element<'a, GuiMessage> {
        Container::new(Scrollable::new(
            Card::new(Text::new("Error"), Text::new(text))
                .style(CardStyles::Danger)
                .on_close(GuiMessage::ErrorDialogClosed),
        ))
        .padding(10)
        .into()
    }
}
