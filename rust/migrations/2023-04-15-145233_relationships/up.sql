CREATE TABLE relationships (
  parent TEXT NOT NULL,
  child TEXT NOT NULL,
  role TEXT NOT NULL,
  PRIMARY KEY (parent, child)
);