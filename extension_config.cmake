duckdb_extension_load(core_functions)
duckdb_extension_load(parquet)
duckdb_extension_load(json)
duckdb_extension_load(icu)
duckdb_extension_load(httpfs
    LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-httpfs
    GIT_TAG 354d3f436a33f80f03a74419e76eb59459e19168
    INCLUDE_DIR extension/httpfs/include
)
duckdb_extension_load(aws
    LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-aws
    GIT_TAG 812ce80fde0bfa6e4641b6fd798087349a610795
)
