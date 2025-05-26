duckdb_extension_load(core_functions)
duckdb_extension_load(parquet)
duckdb_extension_load(json)
duckdb_extension_load(icu)
duckdb_extension_load(httpfs
    GIT_URL https://github.com/duckdb/duckdb-httpfs
    GIT_TAG 00a26970171fe6643078deb3da8d5d322bb9578c
    INCLUDE_DIR extension/httpfs/include
)
duckdb_extension_load(aws
    GIT_URL https://github.com/duckdb/duckdb-aws
    GIT_TAG 4f318ebd088e464266c511abe2f70bbdeee2fcd8
)