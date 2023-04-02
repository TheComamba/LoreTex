use iced::{Sandbox, Settings};

mod gui;

const APP_TITLE: &str = "LoreTex SQL GUI";

pub fn main() -> iced::Result {
    gui_main::SqlGui::run(Settings::default())
}
