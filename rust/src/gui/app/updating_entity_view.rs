use crate::gui::{
    db_col_view::{DbColViewMessage, DbColViewState},
    entity_view::EntityViewState,
};
use loretex::{
    errors::LoreTexError,
    sql::{entity::EntityColumn, lore_database::LoreDatabase},
};

impl EntityViewState {
    pub(super) fn reset(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        self.reset_selections();
        self.update_labels(db)?;
        Ok(())
    }

    fn reset_selections(&mut self) {
        self.label_view_state.selected_entry = None;
        self.descriptor_view_state.selected_entry = None;
        self.current_description = String::new();
    }

    fn update_labels(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        match db {
            Some(db) => self.label_view_state.entries = db.get_all_entity_labels()?,
            None => self.label_view_state = DbColViewState::new(),
        }
        self.update_descriptors(db)?;
        Ok(())
    }

    fn update_descriptors(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let label = &self.label_view_state.selected_entry;
        match db {
            Some(db) => self.descriptor_view_state.entries = db.get_descriptors(label)?,
            None => self.descriptor_view_state = DbColViewState::new(),
        }
        self.update_description(db)?;
        Ok(())
    }

    fn update_description(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let label = match &self.label_view_state.selected_entry {
            Some(label) => label,
            None => {
                self.current_description = "".to_string();
                return Ok(());
            }
        };
        let descriptor = match &self.descriptor_view_state.selected_entry {
            Some(descriptor) => descriptor,
            None => {
                self.current_description = "".to_string();
                return Ok(());
            }
        };
        match db {
            Some(db) => self.current_description = db.get_description(label, descriptor)?,
            None => self.current_description = String::new(),
        }
        Ok(())
    }

    pub(super) fn update_label_view(
        &mut self,
        message: DbColViewMessage,
        db: &Option<LoreDatabase>,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => self.new_entity(db)?,
            DbColViewMessage::SearchFieldUpdated(text) => self.label_view_state.search_text = text,
            DbColViewMessage::Selected(label) => {
                self.label_view_state.selected_entry = Some(label);
                self.descriptor_view_state.selected_entry = None;
                self.update_descriptors(db)?;
            }
        };
        Ok(())
    }

    pub(super) fn update_descriptor_view(
        &mut self,
        message: DbColViewMessage,
        db: &Option<LoreDatabase>,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => self.new_descriptor(db)?,
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.descriptor_view_state.search_text = text
            }
            DbColViewMessage::Selected(descriptor) => {
                self.descriptor_view_state.selected_entry = Some(descriptor);
                self.update_description(db)?;
            }
        };
        Ok(())
    }

    fn new_entity(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let label = self.label_view_state.search_text.clone();
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
        match db {
            Some(db) => db.write_entity_column(new_col)?,
            None => {
                return Err(LoreTexError::InputError(
                    "No database loaded to which to add new entity.".to_string(),
                ));
            }
        };
        self.update_labels(db)?;
        Ok(())
    }

    fn new_descriptor(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let label = match self.label_view_state.selected_entry.as_ref() {
            Some(label) => label.clone(),
            None => {
                return Err(LoreTexError::InputError(
                    "No label selected for which to create new descriptor.".to_string(),
                ));
            }
        };
        let descriptor = self.descriptor_view_state.search_text.clone();
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
        match db {
            Some(db) => db.write_entity_column(new_col)?,
            None => {
                return Err(LoreTexError::InputError(
                    "No database loaded to which to add descriptor.".to_string(),
                ));
            }
        };
        self.update_descriptors(db)?;
        Ok(())
    }
}
