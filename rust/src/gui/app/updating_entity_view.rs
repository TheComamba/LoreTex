use super::SqlGui;
use crate::gui::{
    db_col_view::{state::DbColViewState, ColViewMes},
    dialog::Dialog,
    entity_view::EntityViewState,
};
use loretex::{
    errors::LoreTexError,
    sql::{entity::EntityColumn, lore_database::LoreDatabase},
};

impl SqlGui {
    pub(super) fn update_label_view(&mut self, event: ColViewMes) -> Result<(), LoreTexError> {
        let state = &mut self.entity_view_state;
        match event {
            ColViewMes::New => self.dialog = Some(Dialog::new_entity()),
            ColViewMes::SearchFieldUpd(text) => state.label_view_state.search_text = text,
            ColViewMes::Selected(label) => {
                state.label_view_state.set_selected(label);
                state.descriptor_view_state.set_selected_none();
                state.update_descriptors(&self.lore_database)?;
            }
        };
        Ok(())
    }

    pub(super) fn update_descriptor_view(&mut self, event: ColViewMes) -> Result<(), LoreTexError> {
        let state = &mut self.entity_view_state;
        match event {
            ColViewMes::New => (),
            ColViewMes::SearchFieldUpd(text) => state.descriptor_view_state.search_text = text,
            ColViewMes::Selected(descriptor) => {
                state.descriptor_view_state.set_selected(descriptor);
                state.update_description(&self.lore_database)?;
            }
        };
        Ok(())
    }
}

impl EntityViewState {
    pub(super) fn reset(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        self.reset_selections();
        self.update_labels(db)?;
        Ok(())
    }

    fn reset_selections(&mut self) {
        self.label_view_state.set_selected_none();
        self.descriptor_view_state.set_selected_none();
        self.current_description = String::new();
    }

    fn update_labels(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        match db {
            Some(db) => self
                .label_view_state
                .set_entries(db.get_all_entity_labels()?),
            None => self.label_view_state = DbColViewState::new(),
        }
        self.update_descriptors(db)?;
        Ok(())
    }

    fn update_descriptors(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let label = self.label_view_state.get_selected();
        match db {
            Some(db) => self
                .descriptor_view_state
                .set_entries(db.get_descriptors(&label.as_ref())?),
            None => self.descriptor_view_state = DbColViewState::new(),
        }
        self.update_description(db)?;
        Ok(())
    }

    fn update_description(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let label = match self.label_view_state.get_selected() {
            Some(label) => label,
            None => {
                self.current_description = "".to_string();
                return Ok(());
            }
        };
        let descriptor = match self.descriptor_view_state.get_selected() {
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
        let label = match self.label_view_state.get_selected().as_ref() {
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
