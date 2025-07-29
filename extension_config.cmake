duckdb_extension_load(core_functions)
duckdb_extension_load(parquet)
duckdb_extension_load(json)
duckdb_extension_load(icu)
duckdb_extension_load(httpfs
    LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-httpfs
    GIT_TAG af7bcaf40c775016838fef4823666bd18b89b36b
    INCLUDE_DIR extension/httpfs/include
)
duckdb_extension_load(aws
    LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-aws
    GIT_TAG b73faadeaa4d2c880deb949771baf570f42fe8cc
)