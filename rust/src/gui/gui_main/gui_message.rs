use super::SqlGui;
use crate::gui::db_col_view::DbColViewMessage;

#[derive(Debug, Clone)]
pub enum GuiMessage {
    NewDatabase,
    OpenDatabase,
    LabelViewUpdated(DbColViewMessage),
    DescriptorViewUpdated(DbColViewMessage),
    ErrorDialogClosed,
}

impl SqlGui {
    pub(super) fn update_label_view(&mut self, message: DbColViewMessage) {
        match message {
            DbColViewMessage::SearchFieldUpdated(text) => self.label_view_state.search_text = text,
            DbColViewMessage::Selected(_) => (), //handled elsewhere
        };
    }

    pub(super) fn update_descriptor_view(&mut self, message: DbColViewMessage) {
        match message {
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.descriptor_view_state.search_text = text
            }
            DbColViewMessage::Selected(_) => (), //handled elsewhere
        };
    }
}
