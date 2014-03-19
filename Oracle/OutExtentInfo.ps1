# usage
#     OutExtentInfo [userid] [password] [sid]
#
# PS > . OutExtentInfo.ps1 
# PS > OutExtentInfo scott tiger orcl

[System.Reflection.Assembly]::LoadWithPartialName("Oracle.DataAccess") | Out-Null

function GetUserTableSize {
    param($conn)
    
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand

    $cmd.Connection = $conn
    $cmd.CommandText = @"
select segment_name,count(*),sum(bytes)/1024/1024
from user_extents
where segment_type='TABLE'
group by segment_name
order by segment_name
"@

    $reader = $cmd.ExecuteReader()
    while ($reader.Read())
    {
        @{Name=$reader[0].ToString();
        Size=[Decimal]::Parse($reader[2].ToString());
        Extents=[Int32]::Parse($reader[1].ToString())}
    }
    $reader.Close();
}

function GetCount {
    param($table_name)
    
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand

    $cmd.Connection = $conn
    $cmd.CommandText = "select count(*) from $table_name"
    $reader = $cmd.ExecuteReader()

    if (-not $reader.Read()) { $count = 0 }
    $count = [Int32]::Parse($reader[0].ToString())
    $reader.Close()
    return $count
}
function OutExtentInfo {
    param($uid, $pass, $svc)
    
    $connstr = "User ID=$uid;Password=$pass;Data Source=$svc"
    $conn = New-Object Oracle.DataAccess.Client.OracleConnection($connstr)

    $conn.Open()

    $list = GetUserTableSize $conn

    "{0,-20},{1,10},{2,10},{3,10}" -f "Table Name", "Size(MB)", "Extents", "Count"

    $list | %{
        "{0,-20},{1,10:0.000},{2,10},{3,10}" -f $_.Name, $_.Size, $_.Extents, (GetCount $_.Name)
    }
}