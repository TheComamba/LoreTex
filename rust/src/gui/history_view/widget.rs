use super::HistoryView;
use crate::gui::{app::message_handling::GuiMes, db_col_view::widget::DbColView, style::header};
use iced::{
    widget::{Column, Row, Text},
    Element, Length, Renderer,
};
use iced_lazy::{component, Component};

impl<'a> Component<GuiMes, Renderer> for HistoryView<'a> {
    type State = ();

    type Event = GuiMes;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMes> {
        Some(event)
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        Row::new()
            .push(DbColView::new(
                "Year",
                vec![],
                GuiMes::YearViewUpd,
                &self.state.year_view_state,
            ))
            .push(DbColView::new(
                "Day",
                vec![],
                GuiMes::DayViewUpd,
                &self.state.day_view_state,
            ))
            .push(DbColView::new(
                "Label",
                vec![],
                GuiMes::HistoryLabelViewUpd,
                &self.state.label_view_state,
            ))
            .push(
                Column::new()
                    .push(header("Content"))
                    .push(Text::new(&self.state.current_content))
                    .padding(5)
                    .spacing(5)
                    .width(Length::Fill),
            )
            .into()
    }
}

impl<'a> From<HistoryView<'a>> for Element<'a, GuiMes> {
    fn from(entity_view: HistoryView<'a>) -> Self {
        component(entity_view)
    }
}
