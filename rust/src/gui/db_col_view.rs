use super::{app::message_handling::GuiMessage, style::header};
use iced::{
    widget::{button, Column, Container, Text, TextInput},
    Element, Length, Renderer,
};
use iced_aw::{style::SelectionListStyles, SelectionList};
use iced_lazy::{component, Component};
use loretex::errors::LoreTexError;

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
            self.state.get_visible_entries(),
            DbColViewMessage::Selected,
            20.0,
            0.0,
            SelectionListStyles::Default,
        );
        let mut col = Column::new();
        col = col
            .push(header(self.title))
            .push(search_field)
            .push(Container::new(selection_list).height(Length::Fill));
        for info in self.button_infos.iter() {
            let (text, press_message) = info;
            let mut button = button(Text::new(text)).width(Length::Fill);
            if let Some(message) = press_message.clone() {
                button = button.on_press(message);
            }
            col = col.push(button);
        }
        col.width(Length::Fill)
            .height(Length::Fill)
            .padding(5)
            .spacing(5)
            .into()
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
    entries: Vec<String>,
    selected_entry: Option<String>,
}

impl DbColViewState {
    pub(super) fn new() -> Self {
        DbColViewState {
            search_text: "".to_string(),
            entries: vec![],
            selected_entry: None,
        }
    }

    pub(super) fn get_selected_int(&self) -> Result<Option<i32>, LoreTexError> {
        let year = match self.selected_entry.as_ref() {
            Some(year) => year
                .parse::<i32>()
                .map_err(|e| LoreTexError::InputError(e.to_string()))?,
            None => return Ok(None),
        };
        Ok(Some(year))
    }

    pub(super) fn set_entries(&mut self, mut entries: Vec<String>) {
        if !entries.contains(&String::new()) {
            entries.push(String::new());
        }
        entries.sort();
        entries.dedup();
        self.entries = entries;
    }

    pub(super) fn set_selected(&mut self, entry: String) {
        if entry.is_empty() {
            self.selected_entry = None;
        } else {
            self.selected_entry = Some(entry);
        }
    }

    pub(super) fn set_selected_none(&mut self) {
        self.selected_entry = None;
    }

    pub(super) fn get_selected(&self) -> &Option<String> {
        &self.selected_entry
    }

    fn get_visible_entries(&self) -> Vec<String> {
        match self.search_text.is_empty() {
            true => self.entries.clone(),
            false => {
                let mut visible = vec![String::new()];
                for entry in self.entries.iter() {
                    if entry.contains(&self.search_text) {
                        visible.push(entry.clone());
                    }
                }
                visible
            }
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
