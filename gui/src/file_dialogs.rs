use std::path::PathBuf;

fn current_path() -> PathBuf {
    match std::env::current_dir() {
        Ok(path) => path,
        Err(_) => PathBuf::default(),
    }
}

pub(crate) fn new() -> Option<PathBuf> {
    return rfd::FileDialog::new()
        .set_file_name("new_lore_darabase.db")
        .set_directory(&current_path())
        .save_file();
}

pub(crate) fn open() -> Option<PathBuf> {
    return rfd::FileDialog::new()
        .add_filter("Lore Database (.db)", &["db"])
        .add_filter("Any", &["*"])
        .set_directory(&current_path())
        .pick_file();
}
