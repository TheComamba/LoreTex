use super::{state::DbColViewState, ColViewMes};
use crate::gui::{app::message_handling::GuiMes, style::header};
use iced::{
    widget::{button, Column, Container, Text, TextInput},
    Element, Length, Renderer,
};
use iced_aw::{style::SelectionListStyles, SelectionList};
use iced_lazy::{component, Component};

pub(crate) struct DbColView<'a, M> {
    title: &'a str,
    button_infos: Vec<(String, Option<ColViewMes>)>,
    gui_message: M,
    state: &'a DbColViewState,
}

impl<'a, M> DbColView<'a, M>
where
    M: 'static + Clone + Fn(ColViewMes) -> GuiMes,
{
    pub(crate) fn new(
        title: &'a str,
        button_infos: Vec<(String, Option<ColViewMes>)>,
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

    fn search_field(&self) -> TextInput<ColViewMes> {
        TextInput::new("Type to search...", &self.state.search_text)
            .on_input(ColViewMes::SearchFieldUpd)
            .width(Length::Fill)
    }

    fn selection_list(&self) -> Element<ColViewMes> {
        let selection_list = SelectionList::new_with(
            self.state.get_visible_entries(),
            ColViewMes::Selected,
            20.0,
            0.0,
            SelectionListStyles::Default,
        );
        Container::new(selection_list).height(Length::Fill).into()
    }

    fn button(info: &(String, Option<ColViewMes>)) -> Element<ColViewMes> {
        let (text, press_message) = info;
        let mut button = button(Text::new(text)).width(Length::Fill);
        if let Some(message) = press_message.clone() {
            button = button.on_press(message);
        }
        button.into()
    }
}

impl<'a, M> Component<GuiMes, Renderer> for DbColView<'a, M>
where
    M: 'static + Clone + Fn(ColViewMes) -> GuiMes,
{
    type State = DbColViewState;

    type Event = ColViewMes;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMes> {
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

impl<'a, M> From<DbColView<'a, M>> for Element<'a, GuiMes>
where
    M: 'static + Clone + Fn(ColViewMes) -> GuiMes,
{
    fn from(col_view: DbColView<'a, M>) -> Self {
        component(col_view)
    }
}
