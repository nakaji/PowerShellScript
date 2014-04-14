# 指定されたスキーマのトリガーを一括で有効化/無効化する
# 
# usage
#     ChangeAllTriggers [conn_str] [schema] [status]
#
# PS > ChangeAllTriggers scott/tiger@orcl scott enable

[void][System.Reflection.Assembly]::LoadWithPartialName("Oracle.DataAccess")

function GetConnection {
    param($conn_str)
    
    $params = $conn_str.Split(@("/","@"))
    $connstr = "User ID={0};Password={1};Data Source={2}" -f $params[0],$params[1],$params[2]
    $conn = New-Object Oracle.DataAccess.Client.OracleConnection($connstr)
    $conn.Open()
    
    $conn
}

function GetTriggers {
    param($conn, $owner)
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand

    $cmd.Connection = $conn
    $cmd.CommandText = "select TRIGGER_NAME from ALL_TRIGGERS where OWNER='{0}'" -f $owner
    $reader = $cmd.ExecuteReader()
    while ($reader.Read())
    {
        @{Owner=$owner;
        Name=$reader[0].ToString()
        }
    }
    $reader.Close();
}

function ChangeTriggerStatus {
    param($conn, $triggers, $status)
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand

    $cmd.Connection = $conn
    $triggers | %{
        $sql="alter trigger `"{0}`".`"{1}`" {2}" -f $_.Owner, $_.Name, $status
        "$sql;"
        $cmd.CommandText =  $sql
        [void]$cmd.ExecuteNonQuery()
    }
}

function Main {
param($params)
    $conn_str=$params[0]  #"system/manager@ORCL"
    $schema=$params[1]    #"SCOTT"
    $status=$params[2]    #"DISABLE"

    $conn = GetConnection $conn_str

    $triggers = GetTriggers $conn $schema

    ChangeTriggerStatus $conn $triggers $status

    [void]$conn.Close
}

Main $args
