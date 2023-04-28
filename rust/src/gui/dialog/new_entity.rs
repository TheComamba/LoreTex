use super::{Dialog, DialogType};
use crate::gui::app::message_handling::GuiMes;
use iced::{
    widget::{Button, Column, Text, TextInput},
    Element, Renderer,
};
use iced_lazy::{component, Component};

impl Dialog {
    pub(crate) fn new_entity() -> Self {
        Dialog {
            dialog_type: DialogType::NewEntity(NewEntityDialog {
                label: "".to_string(),
                ent_type: "".to_string(),
            }),
            header: "Create new Entity".to_string(),
        }
    }
}

impl Component<GuiMes, Renderer> for NewEntityDialog {
    type State = ();

    type Event = NewEntityMes;

    fn update(&mut self, _state: &mut Self::State, event: Self::Event) -> Option<GuiMes> {
        match event {
            NewEntityMes::LabelUpd(label) => {
                self.label = label;
                None
            }
            NewEntityMes::TypeUpd(ent_type) => {
                self.ent_type = ent_type;
                None
            }
            NewEntityMes::Submit => Some(GuiMes::DialogClosed),
        }
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        let label_input = TextInput::new("", &self.label).on_input(NewEntityMes::LabelUpd);
        let type_input = TextInput::new("", &self.ent_type).on_input(NewEntityMes::TypeUpd);
        let submit_button = Button::new(Text::new("Create")).on_press(NewEntityMes::Submit);
        Column::new()
            .push(Text::new("Label:"))
            .push(label_input)
            .push(Text::new("Type:"))
            .push(type_input)
            .push(submit_button)
            .padding(5)
            .spacing(5)
            .into()
    }
}

#[derive(Debug, Clone)]
pub(crate) struct NewEntityDialog {
    label: String,
    ent_type: String,
}

impl<'a> From<NewEntityDialog> for Element<'a, GuiMes> {
    fn from(dialog: NewEntityDialog) -> Self {
        component(dialog)
    }
}

#[derive(Debug, Clone)]
pub(crate) enum NewEntityMes {
    LabelUpd(String),
    TypeUpd(String),
    Submit,
}
