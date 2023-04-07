use iced::{
    widget::{button, Column, Text, TextInput},
    Length, Renderer,
};
use iced_aw::{style::SelectionListStyles, SelectionList};

use crate::gui::main_view::message_handling::GuiMessage;

pub(crate) struct DbColViewState {
    pub(crate) search_text: String,
    pub(crate) entries: Vec<String>,
    pub(crate) selected_entry: Option<String>,
}

impl DbColViewState {
    pub(crate) fn new() -> Self {
        DbColViewState {
            search_text: "".to_string(),
            entries: vec![],
            selected_entry: None,
        }
    }
}

#[derive(Debug, Clone)]
pub enum DbColViewMessage {
    New,
    SearchFieldUpdated(String),
    Selected(String),
}

pub(crate) fn db_col_view<'a, M>(
    title: &'a str,
    button_infos: Vec<(&'a str, Option<DbColViewMessage>)>,
    state: &DbColViewState,
    messages: M,
) -> Column<'a, GuiMessage, Renderer>
where
    M: 'static + Clone + Fn(DbColViewMessage) -> GuiMessage,
{
    let m = messages.clone();
    let search_field = TextInput::new("Type to search...", &state.search_text, move |str| {
        m(DbColViewMessage::SearchFieldUpdated(str))
    })
    .width(Length::Fill);
    let m = messages.clone();
    let selection_list = SelectionList::new_with(
        state.entries.clone(),
        move |str| m(DbColViewMessage::Selected(str)),
        20.0,
        0.0,
        SelectionListStyles::Default,
    );
    let mut col = Column::new().push(Text::new(title));
    for info in button_infos.into_iter() {
        let (text, press_message) = info;
        let mut button = button(text).width(Length::Fill);
        if let Some(message) = press_message {
            let m = messages.clone();
            button = button.on_press(m(message));
        }
        col = col.push(button);
    }
    col = col
        .push(search_field)
        .push(selection_list)
        .width(Length::Fill)
        .height(Length::Fill)
        .padding(5)
        .spacing(5);
    col
}