use crate::gui::db_col_view::DbColViewMessage;

pub enum EntityViewMessage {
    LabelViewUpdated(DbColViewMessage),
    DescriptorViewUpdated(DbColViewMessage),
}
