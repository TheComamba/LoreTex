use iced::{Sandbox, Settings};

mod db_col_view;
mod errors;
mod file_dialogs;
mod gui_main;
mod lore_database;
mod schema;
mod user_preferences;

const APP_TITLE: &str = "LoreTex SQL GUI";

pub fn main() -> iced::Result {
    gui_main::SqlGui::run(Settings::default())
}
