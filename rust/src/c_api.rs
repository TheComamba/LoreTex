use std::{path::PathBuf, ffi::{CStr, CString}};

use crate::{
    errors::LoreTexError,
    sql::lore_database::{EntityColumn, LoreDatabase},
};

fn to_entity_column(
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,) -> Result<EntityColumn, LoreTexError> {
    Ok(EntityColumn {
        label: char_pointer_to_string(label)?,
        descriptor: char_pointer_to_string(descriptor)?,
        description: char_pointer_to_string(description)?,
    })
}

fn char_pointer_to_string(string: *const libc::c_char) -> Result<String, LoreTexError> {
    let string: &str = unsafe {
        CStr::from_ptr(string).to_str().map_err(|_| {
            LoreTexError::InputError("Could not convert characterpointer to string.".to_string())
        })?
    };
    Ok(string.to_string())
}

fn char_ptr(message: &str) -> *const libc::c_char {
    CString::new(message).unwrap().into_raw()
}

#[no_mangle]
pub unsafe extern "C" fn write_database_column(
    db_path: *const libc::c_char,
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,
) -> *const libc::c_char {
    let db_path = match char_pointer_to_string(db_path) {
        Ok(s) => s,
        Err(_) => return char_ptr("Database path is not a valid string."),
    };
    let db_path = PathBuf::from(db_path);
    let column = match to_entity_column(label, descriptor, description) {
        Ok(c) => c,
        Err(_) => return char_ptr("Could not transform input to entity column."),
    };
    let db = match LoreDatabase::open(db_path) {
        Ok(db) => db,
        Err(_) => return char_ptr("Could not open database."),
    };
    if db.write_column(column).is_err() {
        char_ptr("Could not write column.")
    } else {
        char_ptr("")
    }
}
