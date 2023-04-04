use std::path::PathBuf;

use crate::{
    errors::LoreTexError,
    sql::lore_database::{EntityColumn, LoreDatabase},
};

#[repr(C)]
pub struct UnsafeEntityColumn {
    label: *const libc::c_char,
    descriptor: *const libc::c_char,
    description: *const libc::c_char,
}

impl UnsafeEntityColumn {
    fn to_entity_column(&self) -> Result<EntityColumn, LoreTexError> {
        let label = char_pointer_to_string(self.label)?;
        let descriptor = char_pointer_to_string(self.descriptor)?;
        let description = char_pointer_to_string(self.description)?;
        Ok(EntityColumn {
            label,
            descriptor,
            description,
        })
    }
}

fn char_pointer_to_string(string: *const libc::c_char) -> Result<String, LoreTexError> {
    let string: &str = unsafe {
        std::ffi::CStr::from_ptr(string).to_str().map_err(|_| {
            LoreTexError::InputError("Could not convert characterpointer to string.".to_string())
        })?
    };
    Ok(string.to_string())
}

#[no_mangle]
pub unsafe extern "C" fn write_database_column(
    db_path: *const libc::c_char,
    column: UnsafeEntityColumn,
) -> i32 {
    let db_path = match char_pointer_to_string(db_path) {
        Ok(s) => s,
        Err(_) => return 1,
    };
    let db_path = PathBuf::from(db_path);
    let column = match column.to_entity_column() {
        Ok(c) => c,
        Err(_) => return 2,
    };
    let db = match LoreDatabase::open(db_path) {
        Ok(db) => db,
        Err(_) => return 3,
    };
    if db.write_column(column).is_err() {
        4
    } else {
        0
    }
}
