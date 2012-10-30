[void][reflection.assembly]::LoadWithPartialName("Oracle.DataAccess")

$conStr = "Data Source=XE;User Id=hr;Password=hr"

$con = New-Object Oracle.DataAccess.Client.OracleConnection($conStr)
$con.Open()

$sqlStr="select segment_name,segment_type,sum(bytes)/1024/1024 as MB 
from user_extents 
group by segment_name,segment_type
order by segment_type,segment_name"

$cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sqlStr, $con)
$reader = $cmd.ExecuteReader()

$outputDataFormat="  {0, -10} {1, -30} {2, 10} {3, 15}"
Write-Host ($outputDataFormat -F "TYPE", "OBJECT_NAME" ,"SIZE(MB)", "RECORD_COUNT")
while ( $reader.read() )
{
    if ($reader[1] -eq "TABLE"){
        $countSql=("select count(*) from {0}" -F $reader[0])
        $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($countSql, $con)
        $countReader = $cmd.ExecuteReader()
        [void]$countReader.read()
        
        Write-Host ($outputDataFormat -F $reader[1] ,$reader[0] ,$reader[2], $countReader[0])
    }else{
        Write-Host ($outputDataFormat -F $reader[1] ,$reader[0] ,$reader[2], "")
    }

}
$con.Close()
