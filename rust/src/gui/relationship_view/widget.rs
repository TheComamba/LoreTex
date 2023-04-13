use super::RelationshipView;
use crate::gui::app::message_handling::GuiMessage;
use iced::{widget::Row, Element, Renderer};
use iced_lazy::{component, Component};

impl Component<GuiMessage, Renderer> for RelationshipView {
    type State = ();

    type Event = GuiMessage;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMessage> {
        None
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        Row::new().into()
    }
}

impl From<RelationshipView> for Element<'_, GuiMessage> {
    fn from(entity_view: RelationshipView) -> Self {
        component(entity_view)
    }
}
