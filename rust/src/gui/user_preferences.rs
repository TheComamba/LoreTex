use loretex::errors::LoreTexError;
use preferences::{AppInfo, Preferences, PreferencesMap};
use std::path::PathBuf;

use crate::APP_TITLE;

const APP_INFO: AppInfo = AppInfo {
    name: APP_TITLE,
    author: "Simon Heidrich",
};

const DATABASE_PATH_KEY: &str = "database_path";

pub(super) fn store_database_path(path: PathBuf) -> Result<(), LoreTexError> {
    let mut path_pref: PreferencesMap<PathBuf> = PreferencesMap::new();
    path_pref.insert(DATABASE_PATH_KEY.to_string(), path.clone());
    path_pref.save(&APP_INFO, DATABASE_PATH_KEY).map_err(|_| {
        LoreTexError::FileError(
            "The following database path could not be stored as user preference:\n".to_string()
                + &path.to_string_lossy(),
        )
    })?;
    Ok(())
}

pub(super) fn load_database_path() -> Option<PathBuf> {
    let path_pref = match PreferencesMap::<PathBuf>::load(&APP_INFO, DATABASE_PATH_KEY) {
        Ok(pref) => pref,
        Err(_) => return None,
    };
    path_pref.get(DATABASE_PATH_KEY).map(|path| path.into())
}
