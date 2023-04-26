use super::RelationshipView;
use crate::gui::{app::message_handling::GuiMessage, db_col_view::DbColView, style::header};
use iced::{
    widget::{Column, Row, Text},
    Element, Length, Renderer,
};
use iced_lazy::{component, Component};

impl<'a> Component<GuiMessage, Renderer> for RelationshipView<'a> {
    type State = ();

    type Event = GuiMessage;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMessage> {
        Some(event)
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        Row::new()
            .push(DbColView::new(
                "Parent",
                vec![],
                GuiMessage::ParentViewUpdated,
                &self.state.parent_view_state,
            ))
            .push(DbColView::new(
                "Child",
                vec![],
                GuiMessage::ChildViewUpdated,
                &self.state.child_view_state,
            ))
            .push(self.role_view())
            .into()
    }
}

impl<'a> RelationshipView<'a> {
    fn role_view(&self) -> Element<'a, GuiMessage> {
        let mut col = Column::new().push(header("Role"));
        if let Some(role) = self.state.current_role.as_ref() {
            col = col.push(Text::new(role));
        }
        col.padding(5).spacing(5).width(Length::Fill).into()
    }
}

impl<'a> From<RelationshipView<'a>> for Element<'a, GuiMessage> {
    fn from(entity_view: RelationshipView<'a>) -> Self {
        component(entity_view)
    }
}
