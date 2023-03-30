use iced::{Sandbox, Settings};

mod db_col_view;
mod errors;
mod gui_main;
mod lore_database;
mod schema;

pub fn main() -> iced::Result {
    gui_main::SqlGui::run(Settings::default())
}
