use iced::widget::{text, Text};

pub(super) fn header<'a>(content: &'a str) -> Text {
    text(content).size(25)
}
