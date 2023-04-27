use loretex::errors::LoreTexError;

#[derive(Debug, Clone)]
pub(crate) struct DbColViewState {
    pub(crate) search_text: String,
    entries: Vec<String>,
    selected_entry: Option<String>,
}

impl DbColViewState {
    pub(crate) fn new() -> Self {
        DbColViewState {
            search_text: "".to_string(),
            entries: vec![],
            selected_entry: None,
        }
    }

    pub(crate) fn get_selected_int(&self) -> Result<Option<i32>, LoreTexError> {
        let year = match self.selected_entry.as_ref() {
            Some(year) => year
                .parse::<i32>()
                .map_err(|e| LoreTexError::InputError(e.to_string()))?,
            None => return Ok(None),
        };
        Ok(Some(year))
    }

    pub(crate) fn set_entries(&mut self, mut entries: Vec<String>) {
        if !entries.contains(&String::new()) {
            entries.push(String::new());
        }
        entries.sort();
        entries.dedup();
        self.entries = entries;
    }

    pub(crate) fn set_selected(&mut self, entry: String) {
        if entry.is_empty() {
            self.selected_entry = None;
        } else {
            self.selected_entry = Some(entry);
        }
    }

    pub(crate) fn set_selected_none(&mut self) {
        self.selected_entry = None;
    }

    pub(crate) fn get_selected(&self) -> &Option<String> {
        &self.selected_entry
    }

    pub(crate) fn get_visible_entries(&self) -> Vec<String> {
        match self.search_text.is_empty() {
            true => self.entries.clone(),
            false => {
                let mut visible = vec![String::new()];
                for entry in self.entries.iter() {
                    if entry.contains(&self.search_text) {
                        visible.push(entry.clone());
                    }
                }
                visible
            }
        }
    }
}

impl Default for DbColViewState {
    fn default() -> Self {
        Self::new()
    }
}
