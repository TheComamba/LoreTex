use super::EntityView;
use crate::gui::{
    app::message_handling::GuiMessage,
    db_col_view::{DbColView, DbColViewMessage},
};
use iced::{
    widget::{Column, Row, Text},
    Alignment, Element, Length, Renderer,
};
use iced_lazy::{component, Component};

impl<'a> Component<GuiMessage, Renderer> for EntityView<'a> {
    type State = ();

    type Event = GuiMessage;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMessage> {
        Some(event)
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        Row::new()
            .push(DbColView::new(
                "Label",
                self.label_button_infos(),
                GuiMessage::EntityLabelViewUpdated,
                &self.state.label_view_state,
            ))
            .push(DbColView::new(
                "Descriptor",
                self.descriptor_button_infos(),
                GuiMessage::DescriptorViewUpdated,
                &self.state.descriptor_view_state,
            ))
            .push(
                Column::new()
                    .push(Text::new("Description"))
                    .push(Text::new(&self.state.current_description))
                    .padding(5)
                    .spacing(5)
                    .width(Length::Fill),
            )
            .align_items(Alignment::Start)
            .width(Length::Fill)
            .height(Length::Fill)
            .into()
    }
}

impl<'a> EntityView<'a> {
    fn new_entity_msg(&self) -> Option<DbColViewMessage> {
        if self.lore_database.is_some() && !self.state.label_view_state.search_text.is_empty() {
            Some(DbColViewMessage::New)
        } else {
            None
        }
    }

    fn new_descriptor_msg(&self) -> Option<DbColViewMessage> {
        if self.state.label_view_state.selected_entry.is_some()
            && !self.state.descriptor_view_state.search_text.is_empty()
        {
            Some(DbColViewMessage::New)
        } else {
            None
        }
    }

    fn label_button_infos(&self) -> Vec<(String, Option<DbColViewMessage>)> {
        vec![
            ("New Entity", self.new_entity_msg()),
            ("Delete Entity", None),
            ("Relabel Entity", None),
        ]
        .into_iter()
        .map(|(s, m)| (s.to_string(), m))
        .collect()
    }

    fn descriptor_button_infos(&self) -> Vec<(String, Option<DbColViewMessage>)> {
        vec![
            ("New Descriptor", self.new_descriptor_msg()),
            ("Delete Descriptor", None),
            ("Rename Descriptor", None),
        ]
        .into_iter()
        .map(|(s, m)| (s.to_string(), m))
        .collect()
    }
}

impl<'a> From<EntityView<'a>> for Element<'a, GuiMessage> {
    fn from(entity_view: EntityView<'a>) -> Self {
        component(entity_view)
    }
}
