CREATE TABLE entities (
  label TEXT NOT NULL,
  descriptor TEXT NOT NULL,
  description TEXT NOT NULL,
  PRIMARY KEY (label, descriptor)
);