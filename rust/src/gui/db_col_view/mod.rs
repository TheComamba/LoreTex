pub(super) mod state;
pub(super) mod widget;

#[derive(Debug, Clone)]
pub(crate) enum ColViewMes {
    New,
    SearchFieldUpd(String),
    Selected(String),
}
