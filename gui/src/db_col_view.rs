use iced::{
    widget::{button, Column, TextInput},
    Alignment, Length, Renderer,
};
use iced_aw::{style::SelectionListStyles, SelectionList};

use crate::gui_main::GuiMessage;

pub(crate) struct DbColViewState {
    pub(crate) search_text: String,
    pub(crate) entries: Vec<String>,
}

impl DbColViewState {
    pub(crate) fn new() -> Self {
        DbColViewState {
            search_text: "".to_string(),
            entries: vec![],
        }
    }
}

#[derive(Debug, Clone)]
pub(crate) enum DbColViewMessage {
    SearchFieldUpdated(String),
    Selected(String),
}

pub(crate) fn db_col_view<'a, M>(
    state: &DbColViewState,
    messages: M,
) -> Column<'a, GuiMessage, Renderer>
where
    M: 'static + Clone + Fn(DbColViewMessage) -> GuiMessage,
{
    let new_button = button("New").width(Length::Fill);
    let delete_button = button("Delete").width(Length::Fill);
    let rename_button = button("Rename").width(Length::Fill);
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
    return Column::new()
        .push(new_button)
        .push(delete_button)
        .push(rename_button)
        .push(search_field)
        .push(selection_list)
        .align_items(Alignment::Center)
        .width(Length::Fill)
        .height(Length::Fill)
        .padding(10);
}
