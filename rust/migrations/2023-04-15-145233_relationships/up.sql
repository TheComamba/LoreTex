CREATE TABLE relationships (
  parent TEXT NOT NULL,
  child TEXT NOT NULL,
  role TEXT,
  PRIMARY KEY (parent, child)
);