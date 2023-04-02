use gui::main_view::SqlGui;
use iced::{Sandbox, Settings};

mod gui;

const APP_TITLE: &str = "LoreTex SQL GUI";

pub fn main() -> iced::Result {
    SqlGui::run(Settings::default())
}
