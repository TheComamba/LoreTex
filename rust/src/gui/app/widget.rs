use super::{message_handling::GuiMessage, SqlGui, ViewType};
use crate::{
    gui::{
        dialog::Dialog,
        entity_view::{EntityView, EntityViewState},
        history_view::{HistoryView, HistoryViewState},
        relationship_view::{RelationshipView, RelationshipViewState},
        user_preferences::load_database_path,
    },
    APP_TITLE,
};
use iced::{
    widget::{button, Button, Column, Container, Row, Text},
    Alignment, Element, Length, Sandbox,
};
use iced_aw::Modal;

impl Sandbox for SqlGui {
    type Message = GuiMessage;

    fn new() -> Self {
        let mut gui = SqlGui {
            selected_view: super::ViewType::Entity,
            entity_view_state: EntityViewState::new(),
            history_view_state: HistoryViewState::new(),
            relationship_view_state: RelationshipViewState::new(),
            lore_database: None,
            error_message: None,
            dialog: None,
        };
        if let Some(path) = load_database_path() {
            match gui.open_database(path) {
                Ok(_) => (),
                Err(e) => gui.error_message = Some(e.to_string()),
            };
        }
        gui
    }

    fn title(&self) -> String {
        APP_TITLE.to_string()
    }

    fn update(&mut self, message: Self::Message) {
        if let Err(e) = self.handle_message(message) {
            self.error_message = Some(e.to_string());
            self.dialog = Some(Dialog::error(e));
        }
    }

    fn view(&self) -> iced::Element<'_, Self::Message> {
        Modal::new(self.dialog.is_some(), self.main_view(), move || {
            self.dialog()
        })
        .on_esc(GuiMessage::DialogClosed)
        .into()
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
            ViewType::History => col = col.push(HistoryView::new(&self.history_view_state)),
            ViewType::Relationship => {
                col = col.push(RelationshipView::new(&self.relationship_view_state))
            }
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

    fn dialog(&self) -> Element<'_, GuiMessage> {
        if let Some(dialog) = self.dialog.as_ref() {
            dialog.clone().into()
        } else {
            Row::new().into()
        }
    }
}
