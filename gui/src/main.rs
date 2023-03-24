use iced::{Sandbox, Settings};

mod db_col_view;
mod errors;
mod gui_main;
mod schema;
mod sql_operations;

pub fn main() -> iced::Result {
    gui_main::SqlGui::run(Settings::default())
}
