use std::path::PathBuf;

pub(crate) fn open() -> Option<PathBuf> {
    let path = match std::env::current_dir() {
        Ok(path) => path,
        Err(_) => PathBuf::default(),
    };
    return rfd::FileDialog::new()
        .add_filter("Lore Database (.db)", &["db"])
        .add_filter("Any", &["*"])
        .set_directory(&path)
        .pick_file();
}
