use super::{SqlGui, ViewType};
use crate::gui::db_col_view::DbColViewMessage;
use loretex::{errors::LoreTexError, sql::entity::EntityColumn};

#[derive(Debug, Clone)]
pub(crate) enum GuiMessage {
    ViewSelected(ViewType),
    NewDatabase,
    OpenDatabase,
    LabelViewUpdated(DbColViewMessage),
    DescriptorViewUpdated(DbColViewMessage),
    ErrorDialogClosed,
}

impl SqlGui {
    pub(super) fn handle_message(&mut self, message: GuiMessage) -> Result<(), LoreTexError> {
        match message {
            GuiMessage::ViewSelected(view) => self.selected_view = view,
            GuiMessage::NewDatabase => self.new_database_from_dialog(),
            GuiMessage::OpenDatabase => self.open_database_from_dialog(),
            GuiMessage::LabelViewUpdated(event) => self.update_label_view(event)?,
            GuiMessage::DescriptorViewUpdated(event) => self.update_descriptor_view(event)?,
            GuiMessage::ErrorDialogClosed => self.error_message = None,
        }
        Ok(())
    }

    fn update_label_view(&mut self, message: DbColViewMessage) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => self.new_entity()?,
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.entity_view_state.label_view_state.search_text = text
            }
            DbColViewMessage::Selected(label) => {
                self.entity_view_state.label_view_state.selected_entry = Some(label);
                self.entity_view_state.descriptor_view_state.selected_entry = None;
                self.update_descriptors();
            }
        };
        Ok(())
    }

    fn update_descriptor_view(&mut self, message: DbColViewMessage) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => self.new_descriptor()?,
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.entity_view_state.descriptor_view_state.search_text = text
            }
            DbColViewMessage::Selected(descriptor) => {
                self.entity_view_state.descriptor_view_state.selected_entry = Some(descriptor);
                self.update_description();
            }
        };
        Ok(())
    }

    fn new_entity(&mut self) -> Result<(), LoreTexError> {
        let label = self.entity_view_state.label_view_state.search_text.clone();
        if label.is_empty() {
            return Err(LoreTexError::InputError(
                "Cannot create entity with empty label.".to_string(),
            ));
        }
        let descriptor = "PLACEHOLDER".to_string();
        let description = String::new();
        let new_col = EntityColumn {
            label,
            descriptor,
            description,
        };
        let db = match self.lore_database.as_ref() {
            Some(db) => db,
            None => {
                return Err(LoreTexError::InputError(
                    "No database loaded to which to add new entity.".to_string(),
                ));
            }
        };
        db.write_column(new_col)?;
        self.update_labels();
        Ok(())
    }

    fn new_descriptor(&mut self) -> Result<(), LoreTexError> {
        let label = match self
            .entity_view_state
            .label_view_state
            .selected_entry
            .as_ref()
        {
            Some(label) => label.clone(),
            None => {
                return Err(LoreTexError::InputError(
                    "No label selected for which to create new descriptor.".to_string(),
                ));
            }
        };
        let descriptor = self
            .entity_view_state
            .descriptor_view_state
            .search_text
            .clone();
        if descriptor.is_empty() {
            return Err(LoreTexError::InputError(
                "Cannot create empty descriptor.".to_string(),
            ));
        }
        let description = String::new();
        let new_col = EntityColumn {
            label,
            descriptor,
            description,
        };
        let db = match self.lore_database.as_ref() {
            Some(db) => db,
            None => {
                return Err(LoreTexError::InputError(
                    "No database loaded to which to add descriptor.".to_string(),
                ));
            }
        };
        db.write_column(new_col)?;
        self.update_descriptors();
        Ok(())
    }
}
