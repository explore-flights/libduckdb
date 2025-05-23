duckdb_extension_load(core_functions)
duckdb_extension_load(parquet)
duckdb_extension_load(json)
duckdb_extension_load(icu)
duckdb_extension_load(httpfs
    GIT_URL https://github.com/duckdb/duckdb-httpfs
    GIT_TAG 217ec8e04f6ed419c866a6d2496aa15aace4382f
    INCLUDE_DIR extension/httpfs/include
)
duckdb_extension_load(aws
    GIT_URL https://github.com/duckdb/duckdb-aws
    GIT_TAG 4f318ebd088e464266c511abe2f70bbdeee2fcd8
)