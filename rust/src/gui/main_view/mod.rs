use loretex::{errors::LoreTexError, sql::lore_database::LoreDatabase};

use super::entities_view::EntitiesViewState;

mod updating;
pub mod widget;

pub struct SqlGui {
    entites_view_state: EntitiesViewState,
    lore_database: Option<LoreDatabase>,
    error_message: Option<String>,
}

impl SqlGui {
    pub fn set_err(&mut self, e: LoreTexError) {
        self.error_message = Some(e.to_string());
    }
}
