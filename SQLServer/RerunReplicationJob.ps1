#レプリケーション関連のジョブを再実行する
#負荷等によりジョブが起動しなかった場合に使う
#https://msdn.microsoft.com/ja-jp/library/ms186722%28v=sql.120%29.aspx?f=255&MSPPError=-2147217396

#$ConnectionString = "Data Source=localhost;Initial Catalog=msdb;User=xx;Password=xx";
$ConnectionString = "Data Source=localhost;Initial Catalog=msdb;Integrated Security=true";
 
$conn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$conn.Open();
 
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.Connection = $conn

$cmd.CommandText = "[sp_help_job] @execution_status =4";
#$cmd.CommandText = "[sp_help_job]";
 
$reader = $cmd.ExecuteReader()
$array = @()

while ($reader.Read())
{
    $name = $reader["name"]
    #アイドル状態 かつ AAA-BBB-CCC-DDD の形式の名前のジョブのみを対象とする
    if (($reader["current_execution_status"] -eq 4) -and ($name.Split("-").Count -eq 4)){
        $array += $name
    }
}
$reader.Close()

$array | %{
    "次のジョブを再実行します ： {0} " -f $_
    
    $cmd.CommandText = "[sp_start_job] N'{0}'" -f $_
    [void]$cmd.ExecuteNonQuery()
}
$cmd.Dispose()