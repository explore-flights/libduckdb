duckdb_extension_load(core_functions)
duckdb_extension_load(parquet)
duckdb_extension_load(json)
duckdb_extension_load(icu)
duckdb_extension_load(httpfs
    GIT_URL https://github.com/duckdb/duckdb-httpfs
    GIT_TAG c22532453e9fab8404f91729708d9f35e23d323d
    INCLUDE_DIR extension/httpfs/include
)
duckdb_extension_load(aws
    GIT_URL https://github.com/duckdb/duckdb-aws
    GIT_TAG e92e45b30ba17594b1101db22699a2244adfaeb1
)