use super::aux::{c_write_entity_column, c_write_history_item, c_write_relationship, char_ptr};

#[no_mangle]
pub unsafe extern "C" fn write_entity_column(
    db_path: *const libc::c_char,
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,
) -> *const libc::c_char {
    match c_write_entity_column(db_path, label, descriptor, description) {
        Ok(()) => char_ptr(""),
        Err(e) => char_ptr(&e.to_string()),
    }
}

#[no_mangle]
pub unsafe extern "C" fn write_history_item(
    db_path: *const libc::c_char,
    label: *const libc::c_char,
    content: *const libc::c_char,
    is_concerns_others: bool,
    is_secret: bool,
    year: i32,
    day: i32,
    originator: *const libc::c_char,
    year_format: *const libc::c_char,
) -> *const libc::c_char {
    match c_write_history_item(
        db_path,
        label,
        content,
        is_concerns_others,
        is_secret,
        year,
        day,
        originator,
        year_format,
    ) {
        Ok(()) => char_ptr(""),
        Err(e) => char_ptr(&e.to_string()),
    }
}

#[no_mangle]
pub unsafe extern "C" fn write_relationship(
    db_path: *const libc::c_char,
    parent: *const libc::c_char,
    child: *const libc::c_char,
    role: *const libc::c_char,
) -> *const libc::c_char {
    match c_write_relationship(db_path, parent, child, role) {
        Ok(()) => char_ptr(""),
        Err(e) => char_ptr(&e.to_string()),
    }
}
