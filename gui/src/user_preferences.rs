use std::path::PathBuf;

use preferences::{AppInfo, Preferences, PreferencesMap};

use crate::{errors::GuiError, APP_TITLE};

const APP_INFO: AppInfo = AppInfo {
    name: APP_TITLE,
    author: "Simon Heidrich",
};

const DATABASE_PATH_KEY: &str = "database_path";

pub(crate) fn store_database_path(path: PathBuf) -> Result<(), GuiError> {
    let mut path_pref: PreferencesMap<PathBuf> = PreferencesMap::new();
    path_pref.insert(DATABASE_PATH_KEY.to_string(), path.clone());
    path_pref.save(&APP_INFO, DATABASE_PATH_KEY).map_err(|_| {
        GuiError::Other(
            "The following database path could not be stored as user preference:\n".to_string()
                + &path.to_string_lossy(),
        )
    })?;
    return Ok(());
}

pub(crate) fn load_database_path() -> Option<PathBuf> {
    let path_pref = match PreferencesMap::<PathBuf>::load(&APP_INFO, DATABASE_PATH_KEY) {
        Ok(pref) => pref,
        Err(_) => return None,
    };
    return match path_pref.get(DATABASE_PATH_KEY) {
        Some(path) => Some(path.into()),
        None => None,
    };
}
