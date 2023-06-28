CREATE OR REPLACE FUNCTION `${project}.${dataset}`.${function_name}(
table_spec STRING,
table_owner STRING,
table_level STRING,
table_domain STRING
) RETURNS JSON

REMOTE WITH CONNECTION `${project}.${region}.${connection_name}`
OPTIONS (
  endpoint = "${cloud_function_url}"
);