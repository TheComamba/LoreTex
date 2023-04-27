use super::{state::DbColViewState, DbColViewMessage};
use crate::gui::{app::message_handling::GuiMessage, style::header};
use iced::{
    widget::{button, Column, Container, Text, TextInput},
    Element, Length, Renderer,
};
use iced_aw::{style::SelectionListStyles, SelectionList};
use iced_lazy::{component, Component};

pub(crate) struct DbColView<'a, M> {
    title: &'a str,
    button_infos: Vec<(String, Option<DbColViewMessage>)>,
    gui_message: M,
    state: &'a DbColViewState,
}

impl<'a, M> DbColView<'a, M>
where
    M: 'static + Clone + Fn(DbColViewMessage) -> GuiMessage,
{
    pub(crate) fn new(
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

    fn title(&self) -> Text {
        header(self.title)
    }

    fn selected(&self) -> Text {
        let content = "Selected: ".to_string()
            + match self.state.get_selected() {
                Some(sel) => sel,
                None => "[None]",
            };
        Text::new(content)
    }

    fn search_field(&self) -> TextInput<DbColViewMessage> {
        TextInput::new("Type to search...", &self.state.search_text)
            .on_input(DbColViewMessage::SearchFieldUpdated)
            .width(Length::Fill)
    }

    fn selection_list(&self) -> Element<DbColViewMessage> {
        let selection_list = SelectionList::new_with(
            self.state.get_visible_entries(),
            DbColViewMessage::Selected,
            20.0,
            0.0,
            SelectionListStyles::Default,
        );
        Container::new(selection_list).height(Length::Fill).into()
    }

    fn button(info: &(String, Option<DbColViewMessage>)) -> Element<DbColViewMessage> {
        let (text, press_message) = info;
        let mut button = button(Text::new(text)).width(Length::Fill);
        if let Some(message) = press_message.clone() {
            button = button.on_press(message);
        }
        button.into()
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
        let mut col = Column::new()
            .push(self.title())
            .push(self.selected())
            .push(self.search_field())
            .push(self.selection_list());

        for info in self.button_infos.iter() {
            col = col.push(Self::button(info));
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
    fn from(col_view: DbColView<'a, M>) -> Self {
        component(col_view)
    }
}
