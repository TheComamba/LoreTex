use super::{SqlGui, ViewType};
use crate::gui::{db_col_view::DbColViewMessage, dialog::DialogMessage};
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
    ParentViewUpdated(DbColViewMessage),
    ChildViewUpdated(DbColViewMessage),
    DialogUpdated(DialogMessage),
    DialogClosed,
}

impl SqlGui {
    pub(super) fn handle_message(&mut self, message: GuiMessage) -> Result<(), LoreTexError> {
        match message {
            GuiMessage::ViewSelected(view) => self.selected_view = view,
            GuiMessage::NewDatabase => self.new_database_from_dialog()?,
            GuiMessage::OpenDatabase => self.open_database_from_dialog()?,
            GuiMessage::EntityLabelViewUpdated(event) => self.update_label_view(event)?,
            GuiMessage::DescriptorViewUpdated(event) => self.update_descriptor_view(event)?,
            GuiMessage::YearViewUpdated(event) => self.update_year_view(event)?,
            GuiMessage::DayViewUpdated(event) => self.update_day_view(event)?,
            GuiMessage::HistoryLabelViewUpdated(event) => self.update_history_label_view(event)?,
            GuiMessage::ParentViewUpdated(event) => self.update_parent_view(event)?,
            GuiMessage::ChildViewUpdated(event) => self.update_child_view(event)?,
            GuiMessage::DialogUpdated(event) => self.update_dialog(event),
            GuiMessage::DialogClosed => self.dialog = None,
        }
        Ok(())
    }
}
