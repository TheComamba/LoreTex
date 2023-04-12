use super::db_col_view::{DbColViewMessage, DbColViewState};

mod message_handling;
pub mod updating;
pub mod widget;

pub(crate) struct EntitiesViewState {
    pub current_description: String,
    pub label_view_state: DbColViewState,
    pub descriptor_view_state: DbColViewState,
}

impl EntitiesViewState {
    fn new_entity_msg(&self) -> Option<DbColViewMessage> {
        if self.lore_database.is_some() && !self.label_view_state.search_text.is_empty() {
            Some(DbColViewMessage::New)
        } else {
            None
        }
    }

    fn new_descriptor_msg(&self) -> Option<DbColViewMessage> {
        if self.label_view_state.selected_entry.is_some()
            && !self.descriptor_view_state.search_text.is_empty()
        {
            Some(DbColViewMessage::New)
        } else {
            None
        }
    }

    fn label_button_infos(&self) -> Vec<(&str, Option<DbColViewMessage>)> {
        vec![
            ("New Entity", self.new_entity_msg()),
            ("Delete Entity", None),
            ("Relabel Entity", None),
        ]
    }

    fn descriptor_button_infos(&self) -> Vec<(&str, Option<DbColViewMessage>)> {
        vec![
            ("New Descriptor", self.new_descriptor_msg()),
            ("Delete Descriptor", None),
            ("Rename Descriptor", None),
        ]
    }

    pub(crate) fn new() -> EntitiesViewState {
        EntitiesViewState {
            label_view_state: DbColViewState::new(),
            descriptor_view_state: DbColViewState::new(),
            current_description: String::new(),
        }
    }
}
