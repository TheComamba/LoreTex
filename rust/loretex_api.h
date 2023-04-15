const char *write_entity_column(const char *db_path,
                                const char *label,
                                const char *descriptor,
                                const char *description);

const char *write_history_item(const char *db_path,
                               const char *label,
                               const char *content,
                               bool is_concerns_others,
                               bool is_secret,
                               int32_t year,
                               int32_t day,
                               const char *originator,
                               const char *year_format);

const char *write_relationship(const char *db_path,
                               const char *parent,
                               const char *child,
                               const char *role);
