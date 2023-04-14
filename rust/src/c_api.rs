use std::{
    ffi::{CStr, CString},
    path::PathBuf,
};

use crate::{
    errors::LoreTexError,
    sql::{entities::EntityColumn, lore_database::LoreDatabase},
};

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

fn char_ptr(message: &str) -> *const libc::c_char {
    CString::new(message).unwrap().into_raw()
}

fn c_write_database_column(
    db_path: *const libc::c_char,
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,
) -> Result<(), LoreTexError> {
    let db_path = char_pointer_to_string(db_path)?;
    let db_path = PathBuf::from(db_path);
    let column = to_entity_column(label, descriptor, description)?;
    let db = LoreDatabase::open(db_path)?;
    db.write_column(column)?;
    Ok(())
}

#[no_mangle]
pub unsafe extern "C" fn write_database_column(
    db_path: *const libc::c_char,
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,
) -> *const libc::c_char {
    match c_write_database_column(db_path, label, descriptor, description) {
        Ok(()) => char_ptr(""),
        Err(e) => char_ptr(&e.to_string()),
    }
}
