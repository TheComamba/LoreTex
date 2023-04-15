use crate::{
    errors::LoreTexError,
    sql::{
        entity::EntityColumn, history::HistoryItem, lore_database::LoreDatabase,
        relationships::EntityRelationship,
    },
};
use std::{
    ffi::{CStr, CString},
    path::PathBuf,
};

fn char_pointer_to_string(string: *const libc::c_char) -> Result<String, LoreTexError> {
    let string: &str = unsafe {
        CStr::from_ptr(string).to_str().map_err(|e| {
            LoreTexError::InputError(
                "Could not convert characterpointer to string.".to_string() + &e.to_string(),
            )
        })?
    };
    Ok(string.to_string())
}

fn char_pointer_to_optional_string(
    string: *const libc::c_char,
) -> Result<Option<String>, LoreTexError> {
    let string = char_pointer_to_string(string)?;
    Ok(if string.is_empty() {
        None
    } else {
        Some(string)
    })
}

pub(super) fn char_ptr(message: &str) -> *const libc::c_char {
    CString::new(message).unwrap().into_raw()
}

fn to_entity_column(
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,
) -> Result<EntityColumn, LoreTexError> {
    Ok(EntityColumn {
        label: char_pointer_to_string(label)?,
        descriptor: char_pointer_to_string(descriptor)?,
        description: char_pointer_to_string(description)?,
    })
}

pub(super) fn c_write_entity_column(
    db_path: *const libc::c_char,
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,
) -> Result<(), LoreTexError> {
    let db_path = char_pointer_to_string(db_path)?;
    let db_path = PathBuf::from(db_path);
    let column = to_entity_column(label, descriptor, description)?;
    let db = LoreDatabase::open(db_path)?;
    db.write_entity_column(column)?;
    Ok(())
}

fn to_history_item(
    label: *const libc::c_char,
    content: *const libc::c_char,
    is_concerns_others: bool,
    is_secret: bool,
    year: i32,
    day: i32,
    originator: *const libc::c_char,
    year_format: *const libc::c_char,
) -> Result<HistoryItem, LoreTexError> {
    let day = if day > 0 { Some(day) } else { None };
    Ok(HistoryItem {
        label: char_pointer_to_string(label)?,
        content: char_pointer_to_string(content)?,
        is_concerns_others,
        is_secret,
        year,
        day,
        originator: char_pointer_to_optional_string(originator)?,
        year_format: char_pointer_to_optional_string(year_format)?,
    })
}

pub(super) fn c_write_history_item(
    db_path: *const libc::c_char,
    label: *const libc::c_char,
    content: *const libc::c_char,
    is_concerns_others: bool,
    is_secret: bool,
    year: i32,
    day: i32,
    originator: *const libc::c_char,
    year_format: *const libc::c_char,
) -> Result<(), LoreTexError> {
    let db_path = char_pointer_to_string(db_path)?;
    let db_path = PathBuf::from(db_path);
    let item = to_history_item(
        label,
        content,
        is_concerns_others,
        is_secret,
        year,
        day,
        originator,
        year_format,
    )?;
    let db = LoreDatabase::open(db_path)?;
    db.write_history_item(item)?;
    Ok(())
}

fn to_relationship(
    parent: *const libc::c_char,
    child: *const libc::c_char,
    role: *const libc::c_char,
) -> Result<EntityRelationship, LoreTexError> {
    Ok(EntityRelationship {
        parent: char_pointer_to_string(parent)?,
        child: char_pointer_to_string(child)?,
        role: char_pointer_to_optional_string(role)?,
    })
}

pub(super) fn c_write_relationship(
    db_path: *const libc::c_char,
    parent: *const libc::c_char,
    child: *const libc::c_char,
    role: *const libc::c_char,
) -> Result<(), LoreTexError> {
    let db_path = char_pointer_to_string(db_path)?;
    let db_path = PathBuf::from(db_path);
    let relationship = to_relationship(parent, child, role)?;
    let db = LoreDatabase::open(db_path)?;
    db.write_relationship(relationship)?;
    Ok(())
}
