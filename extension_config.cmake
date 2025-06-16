duckdb_extension_load(core_functions)
duckdb_extension_load(parquet)
duckdb_extension_load(json)
duckdb_extension_load(icu)
duckdb_extension_load(httpfs
    GIT_URL https://github.com/duckdb/duckdb-httpfs
    GIT_TAG 39779f89b16d0a35f04d3cfaf868e6366a2102f0
    INCLUDE_DIR extension/httpfs/include
)
duckdb_extension_load(aws
    GIT_URL https://github.com/duckdb/duckdb-aws
    GIT_TAG ce6a0965f4f67e82a7dc82ea0378b8b839a2a9aa
)