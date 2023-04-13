use super::app::message_handling::GuiMessage;
use iced::{
    widget::{button, Column, Text, TextInput},
    Element, Length, Renderer,
};
use iced_aw::{style::SelectionListStyles, SelectionList};
use iced_lazy::{component, Component};

pub(super) struct DbColView<'a, M> {
    title: &'a str,
    button_infos: Vec<(String, Option<DbColViewMessage>)>,
    gui_message: M,
    state: &'a DbColViewState,
}

impl<'a, M> DbColView<'a, M>
where
    M: 'static + Clone + Fn(DbColViewMessage) -> GuiMessage,
{
    pub(super) fn new(
        title: &'a str,
        button_infos: Vec<(String, Option<DbColViewMessage>)>,
        gui_message: M,
        state: &'a DbColViewState,
    ) -> Self {
        Self {
            title,
            button_infos,
            gui_message,
            state,
        }
    }
}

impl<'a, M> Component<GuiMessage, Renderer> for DbColView<'a, M>
where
    M: 'static + Clone + Fn(DbColViewMessage) -> GuiMessage,
{
    type State = DbColViewState;

    type Event = DbColViewMessage;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMessage> {
        let m = self.gui_message.clone();
        Some(m(event))
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        let search_field = TextInput::new("Type to search...", &self.state.search_text)
            .on_input(DbColViewMessage::SearchFieldUpdated)
            .width(Length::Fill);
        let selection_list = SelectionList::new_with(
            self.state.entries.clone(),
            DbColViewMessage::Selected,
            20.0,
            0.0,
            SelectionListStyles::Default,
        );
        let mut col = Column::new().push(Text::new(self.title));
        for info in self.button_infos.iter() {
            let (text, press_message) = info;
            let mut button = button(Text::new(text)).width(Length::Fill);
            if let Some(message) = press_message.clone() {
                button = button.on_press(message);
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
        col.into()
    }
}

impl<'a, M> From<DbColView<'a, M>> for Element<'a, GuiMessage>
where
    M: 'static + Clone + Fn(DbColViewMessage) -> GuiMessage,
{
    fn from(entity_view: DbColView<'a, M>) -> Self {
        component(entity_view)
    }
}

#[derive(Debug, Clone)]
pub(super) struct DbColViewState {
    pub(super) search_text: String,
    pub(super) entries: Vec<String>,
    pub(super) selected_entry: Option<String>,
}

impl DbColViewState {
    pub(super) fn new() -> Self {
        DbColViewState {
            search_text: "".to_string(),
            entries: vec![],
            selected_entry: None,
        }
    }
}

impl Default for DbColViewState {
    fn default() -> Self {
        Self::new()
    }
}

#[derive(Debug, Clone)]
pub(crate) enum DbColViewMessage {
    New,
    SearchFieldUpdated(String),
    Selected(String),
}
