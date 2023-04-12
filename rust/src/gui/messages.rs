use super::db_col_view::DbColViewMessage;

#[derive(Debug, Clone)]
pub enum GuiMessage {
    NewDatabase,
    OpenDatabase,
    LabelViewUpdated(DbColViewMessage),
    DescriptorViewUpdated(DbColViewMessage),
    ErrorDialogClosed,
}
