use gui::app::SqlGui;
use iced::{Sandbox, Settings};

mod gui;

const APP_TITLE: &str = "LoreTex SQL GUI";

fn main() -> iced::Result {
    SqlGui::run(Settings::default())
}
