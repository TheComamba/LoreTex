use super::entity_view::EntityViewState;
use loretex::sql::lore_database::LoreDatabase;

pub mod message_handling;
mod updating;
pub mod updating_entity_view;
pub mod widget;

pub struct SqlGui {
    selected_view: ViewType,
    entity_view_state: EntityViewState,
    lore_database: Option<LoreDatabase>,
    error_message: Option<String>,
}

#[derive(Debug, Clone)]
pub enum ViewType {
    Entity,
    History,
    Relationship,
}
