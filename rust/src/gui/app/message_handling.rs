use super::{SqlGui, ViewType};
use crate::gui::db_col_view::DbColViewMessage;
use loretex::errors::LoreTexError;

#[derive(Debug, Clone)]
pub(crate) enum GuiMessage {
    ViewSelected(ViewType),
    NewDatabase,
    OpenDatabase,
    EntityLabelViewUpdated(DbColViewMessage),
    DescriptorViewUpdated(DbColViewMessage),
    YearViewUpdated(DbColViewMessage),
    DayViewUpdated(DbColViewMessage),
    HistoryLabelViewUpdated(DbColViewMessage),
    ErrorDialogClosed,
}

impl SqlGui {
    pub(super) fn handle_message(&mut self, message: GuiMessage) -> Result<(), LoreTexError> {
        match message {
            GuiMessage::ViewSelected(view) => self.selected_view = view,
            GuiMessage::NewDatabase => self.new_database_from_dialog(),
            GuiMessage::OpenDatabase => self.open_database_from_dialog(),
            GuiMessage::EntityLabelViewUpdated(event) => self.update_entity_label_view(event)?,
            GuiMessage::DescriptorViewUpdated(event) => self.update_descriptor_view(event)?,
            GuiMessage::YearViewUpdated(_) => (),
            GuiMessage::DayViewUpdated(_) => (),
            GuiMessage::HistoryLabelViewUpdated(_) => (),
            GuiMessage::ErrorDialogClosed => self.error_message = None,
        }
        Ok(())
    }
}
