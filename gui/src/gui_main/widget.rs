use crate::{
    db_col_view::{db_col_view, DbColViewMessage, DbColViewState},
    user_preferences::load_database_path,
    APP_TITLE,
};

use super::{gui_message::GuiMessage, SqlGui};
use iced::{
    widget::{Button, Column, Container, Row, Scrollable, Text},
    Alignment, Length, Sandbox,
};
use iced_aw::{style::CardStyles, Card};

impl Sandbox for SqlGui {
    type Message = GuiMessage;

    fn new() -> Self {
        let mut gui = SqlGui {
            label_view_state: DbColViewState::new(),
            descriptor_view_state: DbColViewState::new(),
            current_description: String::new(),
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
        match message {
            GuiMessage::NewDatabase => self.new_database_from_dialog(),
            GuiMessage::OpenDatabase => self.open_database_from_dialog(),
            GuiMessage::LabelViewUpdated(DbColViewMessage::Selected(label)) => {
                self.label_view_state.selected_entry = Some(label);
                self.descriptor_view_state.selected_entry = None;
                self.update_descriptors();
            }
            GuiMessage::DescriptorViewUpdated(DbColViewMessage::Selected(descriptor)) => {
                self.descriptor_view_state.selected_entry = Some(descriptor);
                self.update_description();
            }
            GuiMessage::LabelViewUpdated(event) => self.update_label_view(event),
            GuiMessage::DescriptorViewUpdated(event) => self.update_descriptor_view(event),
            GuiMessage::ErrorDialogClosed => self.error_message = None,
        }
    }

    fn view(&self) -> iced::Element<'_, Self::Message> {
        match self.error_message.clone() {
            None => Column::new()
                .push(self.menu_bar())
                .push(self.current_database_display())
                .push(self.main_view())
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

    fn main_view(&self) -> iced::Element<'_, GuiMessage> {
        Row::new()
            .push(db_col_view(
                "Labels",
                &self.label_view_state,
                GuiMessage::LabelViewUpdated,
            ))
            .push(db_col_view(
                "Descriptors",
                &self.descriptor_view_state,
                GuiMessage::DescriptorViewUpdated,
            ))
            .push(
                Column::new()
                    .push(Text::new("Description"))
                    .push(Text::new(&self.current_description))
                    .padding(5)
                    .spacing(5)
                    .width(Length::Fill),
            )
            .align_items(Alignment::Start)
            .width(Length::Fill)
            .height(Length::Fill)
            .into()
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
