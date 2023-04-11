extern crate cbindgen;

use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    cbindgen::Builder::new()
        .with_crate(crate_dir)
        .with_no_includes()
        .with_language(cbindgen::Language::C)
        .generate()
        .expect("Unable to generate C header file.")
        .write_to_file("loretex_api.h");
}
