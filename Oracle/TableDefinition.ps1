[System.Reflection.Assembly]::LoadWithPartialName("Oracle.DataAccess") | Out-Null
cls

function GetUserTables {
param($uid, $pass, $svc)
    $connstr = "User ID=$uid;Password=$pass;Data Source=$svc"
    $conn = New-Object Oracle.DataAccess.Client.OracleConnection($connstr)

    $conn.Open()
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand

    $cmd.Connection = $conn
    $cmd.CommandText = "select TABLE_NAME from USER_TABLES order by TABLE_NAME"

    $reader = $cmd.ExecuteReader()
    while ($reader.Read())
    {
        $reader[0].ToString()
    }
}

function OutputDefiniton {
param($uid, $pass, $svc, $talbes)

    if (!(Test-Path $uid)) { mkdir $uid | Out-Null }
    $talbes | %{
        $tableName=$_
        "desc $tableName" | sqlplus -S $uid/$pass@$svc | Out-File "$uid\$tableName.def" -Encoding default
    }
}

$uid = Read-Host "UserID:"
$pass = Read-Host "Password:"
$svc = Read-Host "ServiceName:"

$talbes = GetUserTables $uid $pass $svc

OutputDefiniton $uid $pass $svc $talbes

trap{ exit }