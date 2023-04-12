use iced::{
    widget::{Column, Row, Text},
    Alignment, Length,
};

use crate::gui::{db_col_view::db_col_view, messages::GuiMessage};

use super::EntitiesViewState;

pub fn entities_view(state: &EntitiesViewState) -> iced::Element<'_, GuiMessage> {
    Row::new()
        .push(db_col_view(
            "Labels",
            state.label_button_infos(),
            &state.label_view_state,
            GuiMessage::LabelViewUpdated,
        ))
        .push(db_col_view(
            "Descriptors",
            state.descriptor_button_infos(),
            &state.descriptor_view_state,
            GuiMessage::DescriptorViewUpdated,
        ))
        .push(
            Column::new()
                .push(Text::new("Description"))
                .push(Text::new(&state.current_description))
                .padding(5)
                .spacing(5)
                .width(Length::Fill),
        )
        .align_items(Alignment::Start)
        .width(Length::Fill)
        .height(Length::Fill)
        .into()
}
