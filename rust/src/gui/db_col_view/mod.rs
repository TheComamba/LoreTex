pub(super) mod state;
pub(super) mod widget;

#[derive(Debug, Clone)]
pub(crate) enum DbColViewMessage {
    New,
    SearchFieldUpdated(String),
    Selected(String),
}
