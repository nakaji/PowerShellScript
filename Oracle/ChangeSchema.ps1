#
# スキーマを移動するためのスクリプト
#   expdpを使用するがダンプファイルは削除しないので手動で消す必要あり
#

$conn_str=$args[0]      #"system/manager@ORCL"
$schema_from=$args[1]   #"SCOTT"
$schema_to=$args[2]     #"TIGER"
$table_name=$args[3]    #"EMP"
$dir="DATA_PUMP_DIR"

expdp $conn_str directory=$dir dumpfile=${table_name}.dmp logfile=${table_name}_exp.log tables=${schema_from}.${table_name} reuse_dumpfiles=Y
if ($lastexitcode -ne 0) { exit 1 }

"drop table ${schema_from}.${table_name} purge;" | sqlplus $conn_str
if ($lastexitcode -ne 0) { exit 1 }

impdp $conn_str directory=$dir dumpfile=${table_name}.dmp logfile=${table_name}_imp.log tables=${schema_from}.${table_name} remap_schema=${schema_from}:${schema_to}
if ($lastexitcode -ne 0) { exit 1 }
