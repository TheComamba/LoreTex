use super::{Dialog, DialogType};
use crate::gui::app::message_handling::GuiMes;
use iced::{
    widget::{Button, Column, Text},
    Element, Renderer,
};
use iced_lazy::{component, Component};
use loretex::errors::LoreTexError;

impl Dialog {
    pub(crate) fn error(error: LoreTexError) -> Self {
        Dialog {
            dialog_type: DialogType::Error(ErrorDialog { error }),
            header: "Error".to_string(),
        }
    }
}

#[derive(Debug, Clone)]
pub(crate) struct ErrorDialog {
    error: LoreTexError,
}

impl Component<GuiMes, Renderer> for ErrorDialog {
    type State = ();

    type Event = ErrorDialogMes;

    fn update(&mut self, _state: &mut Self::State, _event: Self::Event) -> Option<GuiMes> {
        Some(GuiMes::DialogClosed)
    }

    fn view(&self, _state: &Self::State) -> Element<'_, Self::Event, Renderer> {
        let text = Text::new(self.error.to_string());
        let button = Button::new(Text::new("Ok")).on_press(ErrorDialogMes::Close);
        Column::new().push(text).push(button).into()
    }
}

impl<'a> From<ErrorDialog> for Element<'a, GuiMes> {
    fn from(dialog: ErrorDialog) -> Self {
        component(dialog)
    }
}

#[derive(Debug, Clone)]
pub(crate) enum ErrorDialogMes {
    Close,
}
