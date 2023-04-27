use super::HistoryView;
use crate::gui::{
    app::message_handling::GuiMessage, db_col_view::widget::DbColView, style::header,
};
use iced::{
    widget::{Column, Row, Text},
    Element, Length, Renderer,
};
use iced_lazy::{component, Component};

impl<'a> Component<GuiMessage, Renderer> for HistoryView<'a> {
    type State = ();

    type Event = GuiMessage;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMessage> {
        Some(event)
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        Row::new()
            .push(DbColView::new(
                "Year",
                vec![],
                GuiMessage::YearViewUpdated,
                &self.state.year_view_state,
            ))
            .push(DbColView::new(
                "Day",
                vec![],
                GuiMessage::DayViewUpdated,
                &self.state.day_view_state,
            ))
            .push(DbColView::new(
                "Label",
                vec![],
                GuiMessage::HistoryLabelViewUpdated,
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

impl<'a> From<HistoryView<'a>> for Element<'a, GuiMessage> {
    fn from(entity_view: HistoryView<'a>) -> Self {
        component(entity_view)
    }
}
