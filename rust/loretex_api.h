typedef struct UnsafeEntityColumn {
  const char *label;
  const char *descriptor;
  const char *description;
} UnsafeEntityColumn;

int32_t write_database_column(const char *db_path, struct UnsafeEntityColumn column);
