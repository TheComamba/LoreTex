use super::aux::{c_write_entity_column, char_ptr};

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
