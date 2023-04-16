use loretex::{errors::LoreTexError, sql::lore_database::LoreDatabase};

use crate::gui::{db_col_view::DbColViewMessage, relationship_view::RelationshipViewState};

impl RelationshipViewState {
    pub(super) fn update_parent_view(
        &mut self,
        message: DbColViewMessage,
        db: &Option<LoreDatabase>,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => (),
            DbColViewMessage::SearchFieldUpdated(text) => self.parent_view_state.search_text = text,
            DbColViewMessage::Selected(parent) => {
                self.parent_view_state.selected_entry = Some(parent);
                self.update_children(db)?;
                self.update_role(db)?;
            }
        };
        Ok(())
    }

    pub(super) fn update_child_view(
        &mut self,
        message: DbColViewMessage,
        db: &Option<LoreDatabase>,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => (),
            DbColViewMessage::SearchFieldUpdated(text) => self.child_view_state.search_text = text,
            DbColViewMessage::Selected(child) => {
                self.child_view_state.selected_entry = Some(child);
                self.update_parents(db)?;
                self.update_role(db)?;
            }
        };
        Ok(())
    }

    pub(super) fn reset(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        self.reset_selections();
        self.update_parents(db)?;
        self.update_children(db)?;
        Ok(())
    }

    fn reset_selections(&mut self) {
        self.parent_view_state.selected_entry = None;
        self.child_view_state.selected_entry = None;
        self.current_role = None;
    }

    fn update_parents(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let child = &self.child_view_state.selected_entry;
        match db {
            Some(db) => self.parent_view_state.entries = db.get_parents(&child.as_ref())?,
            None => self.parent_view_state.entries = vec![],
        }
        Ok(())
    }

    fn update_children(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let parent = &self.parent_view_state.selected_entry;
        match db {
            Some(db) => self.child_view_state.entries = db.get_children(&parent.as_ref())?,
            None => self.child_view_state.entries = vec![],
        }
        Ok(())
    }

    fn update_role(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let parent = match &self.parent_view_state.selected_entry {
            Some(parent) => parent,
            None => {
                self.current_role = None;
                return Ok(());
            }
        };
        let child = match &self.child_view_state.selected_entry {
            Some(child) => child,
            None => {
                self.current_role = None;
                return Ok(());
            }
        };
        match db {
            Some(db) => self.current_role = db.get_relationship_role(parent, child)?,
            None => self.current_role = None,
        }
        Ok(())
    }
}
