use super::{Dialog, DialogMes, DialogType};
use crate::gui::app::{message_handling::GuiMes, SqlGui};
use iced::{
    widget::{Button, Column, Text, TextInput},
    Element,
};

impl SqlGui {
    pub(super) fn update_new_entity_dialog(&mut self, event: NewEntityMes) {
        match event {
            NewEntityMes::LabelUpd(str) => self.dialog = Some(Dialog::new_entity()),
            NewEntityMes::TypeUpd(str) => self.dialog = Some(Dialog::new_entity()),
            NewEntityMes::Submit => self.dialog = None,
        };
    }
}

impl Dialog {
    pub(crate) fn new_entity() -> Self {
        Dialog {
            dialog_type: DialogType::NewEntity {
                label: "".to_string(),
                ent_type: "".to_string(),
            },
            header: "Create new Entity".to_string(),
        }
    }

    pub(super) fn new_entity_content<'a>(
        &self,
        label: &String,
        ent_type: &String,
    ) -> Element<'a, GuiMes> {
        let label_input = TextInput::new("", label)
            .on_input(|str| GuiMes::DialogUpd(DialogMes::NewEntity(NewEntityMes::LabelUpd(str))));
        let type_input = TextInput::new("", &ent_type)
            .on_input(|str| GuiMes::DialogUpd(DialogMes::NewEntity(NewEntityMes::TypeUpd(str))));
        let submit_button = Button::new(Text::new("Create")).on_press(GuiMes::DialogUpd(
            DialogMes::NewEntity(NewEntityMes::Submit),
        ));
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
pub(crate) enum NewEntityMes {
    LabelUpd(String),
    TypeUpd(String),
    Submit,
}
