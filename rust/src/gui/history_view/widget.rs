use super::HistoryView;
use crate::gui::{
    app::message_handling::GuiMessage,
    db_col_view::{DbColView, DbColViewMessage},
};
use iced::{widget::Row, Element, Renderer};
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
                "Labels",
                self.label_button_infos(),
                GuiMessage::LabelViewUpdated,
                &self.state.label_view_state,
            ))
            .into()
    }
}

impl<'a> HistoryView<'a> {
    fn label_button_infos(&self) -> Vec<(String, Option<DbColViewMessage>)> {
        vec![("New History Item", None), ("Delete History Item", None)]
            .into_iter()
            .map(|(s, m)| (s.to_string(), m))
            .collect()
    }
}

impl<'a> From<HistoryView<'a>> for Element<'a, GuiMessage> {
    fn from(entity_view: HistoryView<'a>) -> Self {
        component(entity_view)
    }
}
