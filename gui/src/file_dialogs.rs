pub(crate) fn open() -> Option<String> {
    let path = match std::env::current_dir() {
        Ok(path) => path,
        Err(_) => "/",
    };
    return rfd::FileDialog::new().set_directory(&path).pick_file();
}
