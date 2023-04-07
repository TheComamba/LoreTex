#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

struct UnsafeEntityColumn {
  const char *label;
  const char *descriptor;
  const char *description;
};

extern "C" {

int32_t write_database_column(const char *db_path, UnsafeEntityColumn column);

} // extern "C"
