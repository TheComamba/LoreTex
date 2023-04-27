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
    ParentViewUpdated(DbColViewMessage),
    ChildViewUpdated(DbColViewMessage),
    DialogClosed,
}

impl SqlGui {
    pub(super) fn handle_message(&mut self, message: GuiMessage) -> Result<(), LoreTexError> {
        match message {
            GuiMessage::ViewSelected(view) => self.selected_view = view,
            GuiMessage::NewDatabase => self.new_database_from_dialog()?,
            GuiMessage::OpenDatabase => self.open_database_from_dialog()?,
            GuiMessage::EntityLabelViewUpdated(event) => self
                .entity_view_state
                .update_label_view(event, &self.lore_database)?,
            GuiMessage::DescriptorViewUpdated(event) => self
                .entity_view_state
                .update_descriptor_view(event, &self.lore_database)?,
            GuiMessage::YearViewUpdated(event) => self
                .history_view_state
                .update_year_view(event, &self.lore_database)?,
            GuiMessage::DayViewUpdated(event) => self
                .history_view_state
                .update_day_view(event, &self.lore_database)?,
            GuiMessage::HistoryLabelViewUpdated(event) => self
                .history_view_state
                .update_label_view(event, &self.lore_database)?,
            GuiMessage::ParentViewUpdated(event) => self
                .relationship_view_state
                .update_parent_view(event, &self.lore_database)?,
            GuiMessage::ChildViewUpdated(event) => self
                .relationship_view_state
                .update_child_view(event, &self.lore_database)?,
            GuiMessage::DialogClosed => self.dialog = None,
        }
        Ok(())
    }
}
