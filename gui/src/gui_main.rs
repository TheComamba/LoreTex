use iced::{
    widget::{Container, Row, Scrollable, Text, TextInput},
    Alignment, Length, Sandbox,
};
use iced_aw::{style::CardStyles, Card};

use crate::{
    db_col_view::{db_col_view, DbColViewMessage, DbColViewState},
    sql_operations::{get_all_labels, run_migrations},
};

#[derive(Debug, Clone)]
pub(crate) enum GuiMessage {
    DescriptionUpdated(String),
    LabelViewUpdated(DbColViewMessage),
    DescriptorViewUpdated(DbColViewMessage),
    ErrorDialogClosed,
}

pub(crate) struct SqlGui {
    label_view_state: DbColViewState,
    descriptor_view_state: DbColViewState,
    current_description: String,
    error_message: Option<String>,
}

impl Sandbox for SqlGui {
    type Message = GuiMessage;

    fn new() -> Self {
        let mut gui = SqlGui {
            label_view_state: DbColViewState::new(),
            descriptor_view_state: DbColViewState::new(),
            current_description: String::new(),
            error_message: None,
        };
        if let Err(e) = run_migrations() {
            gui.error_message = Some(e.to_string());
            return gui;
        }
        gui.update_labels();
        return gui;
    }

    fn title(&self) -> String {
        "LoreTex SQL GUI".to_string()
    }

    fn update(&mut self, message: Self::Message) {
        match message {
            GuiMessage::LabelViewUpdated(DbColViewMessage::Selected(label)) => {
                self.label_view_state.selected_entry = Some(label);
            }
            GuiMessage::DescriptorViewUpdated(DbColViewMessage::Selected(descriptor)) => {
                self.descriptor_view_state.selected_entry = Some(descriptor);
            }
            GuiMessage::LabelViewUpdated(event) => self.update_label_view(event),
            GuiMessage::DescriptorViewUpdated(event) => self.update_descriptor_view(event),
            GuiMessage::ErrorDialogClosed => self.error_message = None,
            GuiMessage::DescriptionUpdated(_) => {
                self.error_message = Some("Not yet implemented".to_string())
            }
        }
    }

    fn view(&self) -> iced::Element<'_, Self::Message> {
        match self.error_message.clone() {
            None => return self.main_view(),
            Some(message) => return self.error_dialog(message),
        }
    }
}

impl SqlGui {
    fn update_label_view(&mut self, message: DbColViewMessage) {
        match message {
            DbColViewMessage::SearchFieldUpdated(text) => self.label_view_state.search_text = text,
            DbColViewMessage::Selected(_) => (), //handled elsewhere
        };
    }

    fn update_descriptor_view(&mut self, message: DbColViewMessage) {
        match message {
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.descriptor_view_state.search_text = text
            }
            DbColViewMessage::Selected(_) => (), //handled elsewhere
        };
    }

    fn main_view(&self) -> iced::Element<'_, GuiMessage> {
        return Row::new()
            .push(db_col_view(
                &self.label_view_state,
                GuiMessage::LabelViewUpdated,
            ))
            .push(db_col_view(
                &self.descriptor_view_state,
                GuiMessage::DescriptorViewUpdated,
            ))
            .push(TextInput::new(
                "Description",
                &self.current_description,
                GuiMessage::DescriptionUpdated,
            ))
            .align_items(Alignment::Center)
            .width(Length::Fill)
            .height(Length::Fill)
            .into();
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

    fn update_labels(&mut self) {
        match get_all_labels() {
            Ok(labels) => self.label_view_state.entries = labels,
            Err(e) => {
                self.error_message = Some(e.to_string());
                self.label_view_state.entries = vec![];
            }
        };
    }
}
