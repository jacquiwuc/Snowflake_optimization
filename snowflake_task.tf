# https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/task

resource "snowflake_task" "resource_name" {
  comment = "task of creating table in snowflake"
  
  for_each  = var.variable_name
  database  = snowflake_database.database_name.name
  schema    = "SCHEMA_NAME"
  warehouse = snowflake_warehouse.warehouse_name.name

  name = format("%s%s%s%s", var.vars_prefix, "_GA_DATA_", each.value.name, "_NAME")

  schedule = "USING CRON 30 7,12 * * * Pacific/Auckland"
  session_parameters = {
    "ODBC_QUERY_RESULT_FORMAT" = "ARROW"
  }
  sql_statement = var.vars_prefix == "DEV" ? file(format("%s%s%s", "../folder_name/folder_name/QUERY_NAME_PREFIX", each.value.name, "_NAME.sql")) : file(format("%s%s%s", "../folder_name/folder_name/QUERY_NAME_PREFIX", each.value.name, "_NAME.sql"))

  enabled = each.value.task_enabled

}
