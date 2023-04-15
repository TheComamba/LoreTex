use super::{entity_view::EntityViewState, history_view::HistoryViewState};
use loretex::sql::lore_database::LoreDatabase;

pub(super) mod message_handling;
mod updating_database;
mod updating_entity_view;
mod updating_history_view;
mod widget;

pub(crate) struct SqlGui {
    selected_view: ViewType,
    entity_view_state: EntityViewState,
    history_view_state: HistoryViewState,
    lore_database: Option<LoreDatabase>,
    error_message: Option<String>,
}

#[derive(Debug, Clone)]
pub(crate) enum ViewType {
    Entity,
    History,
    Relationship,
}
