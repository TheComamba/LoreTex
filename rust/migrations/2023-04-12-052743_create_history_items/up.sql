CREATE TABLE history_items (
  label TEXT NOT NULL,
  content TEXT NOT NULL,
  is_concerns_others BOOLEAN NOT NULL,
  is_secret BOOLEAN NOT NULL,
  year INTEGER NOT NULL,
  day INTEGER,
  originator TEXT,
  year_format TEXT,
  PRIMARY KEY (label)
);