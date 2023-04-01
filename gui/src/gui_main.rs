use iced::{
    widget::{Button, Column, Container, Row, Scrollable, Text},
    Alignment, Length, Sandbox,
};
use iced_aw::{style::CardStyles, Card};

use crate::{
    db_col_view::{db_col_view, DbColViewMessage, DbColViewState},
    file_dialogs,
    lore_database::LoreDatabase,
};

#[derive(Debug, Clone)]
pub(crate) enum GuiMessage {
    NewDatabase,
    OpenDatabase,
    LabelViewUpdated(DbColViewMessage),
    DescriptorViewUpdated(DbColViewMessage),
    ErrorDialogClosed,
}

pub(crate) struct SqlGui {
    label_view_state: DbColViewState,
    descriptor_view_state: DbColViewState,
    current_description: String,
    lore_database: Option<LoreDatabase>,
    error_message: Option<String>,
}

impl Sandbox for SqlGui {
    type Message = GuiMessage;

    fn new() -> Self {
        let gui = SqlGui {
            label_view_state: DbColViewState::new(),
            descriptor_view_state: DbColViewState::new(),
            current_description: String::new(),
            lore_database: None,
            error_message: None,
        };
        return gui;
    }

    fn title(&self) -> String {
        "LoreTex SQL GUI".to_string()
    }

    fn update(&mut self, message: Self::Message) {
        match message {
            GuiMessage::NewDatabase => self.new_database(),
            GuiMessage::OpenDatabase => self.open_database(),
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
            None => {
                return Column::new()
                    .push(self.menu_bar())
                    .push(self.main_view())
                    .into()
            }
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

    fn menu_bar(&self) -> iced::Element<'_, GuiMessage> {
        return Row::new()
            .push(Button::new("New Lore Database").on_press(GuiMessage::NewDatabase))
            .push(Button::new("Open Lore Database").on_press(GuiMessage::OpenDatabase))
            .align_items(Alignment::Center)
            .width(Length::Fill)
            .padding(5)
            .spacing(5)
            .into();
    }

    fn main_view(&self) -> iced::Element<'_, GuiMessage> {
        return Row::new()
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

    fn new_database(&mut self) {
        let path = match file_dialogs::new() {
            Some(path) => path,
            None => return,
        };
        self.lore_database = match LoreDatabase::new(path) {
            Ok(db) => Some(db),
            Err(e) => {
                self.error_message = Some(e.to_string());
                None
            }
        };
        self.update_labels();
    }

    fn open_database(&mut self) {
        let path = match file_dialogs::open() {
            Some(path) => path,
            None => return,
        };
        self.lore_database = match LoreDatabase::open(path) {
            Ok(db) => Some(db),
            Err(e) => {
                self.error_message = Some(e.to_string());
                None
            }
        };
        self.update_labels();
    }

    fn update_labels(&mut self) {
        match self.lore_database.as_ref() {
            Some(db) => match db.get_all_labels() {
                Ok(labels) => self.label_view_state.entries = labels,
                Err(e) => {
                    self.error_message = Some(e.to_string());
                    self.label_view_state.entries = vec![];
                }
            },
            None => self.label_view_state = DbColViewState::new(),
        }
        self.update_descriptors();
    }

    fn update_descriptors(&mut self) {
        let label = match &self.label_view_state.selected_entry {
            Some(label) => label,
            None => {
                self.descriptor_view_state.entries = vec![];
                return;
            }
        };
        match self.lore_database.as_ref() {
            Some(db) => match db.get_all_descriptors(label) {
                Ok(descriptors) => self.descriptor_view_state.entries = descriptors,
                Err(e) => {
                    self.error_message = Some(e.to_string());
                    self.descriptor_view_state.entries = vec![];
                    return;
                }
            },
            None => self.descriptor_view_state = DbColViewState::new(),
        }
        self.update_description();
    }

    fn update_description(&mut self) {
        let label = match &self.label_view_state.selected_entry {
            Some(label) => label,
            None => {
                self.current_description = "".to_string();
                return;
            }
        };
        let descriptor = match &self.descriptor_view_state.selected_entry {
            Some(descriptor) => descriptor,
            None => {
                self.current_description = "".to_string();
                return;
            }
        };
        match self.lore_database.as_ref() {
            Some(db) => match db.get_description(label, descriptor) {
                Ok(desc) => self.current_description = desc,
                Err(e) => self.error_message = Some(e.to_string()),
            },
            None => self.current_description = String::new(),
        }
    }
}
