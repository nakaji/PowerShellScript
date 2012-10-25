# 参考:http://www.atmarkit.co.jp/fdb/rensai/ora_backup07/ora_backup07_2.html
#alter database begin backup という方法もあり
[void][reflection.assembly]::LoadWithPartialName("Oracle.DataAccess")

$conStr = "Data Source=XE;User Id=/;DBA Privilege=SYSDBA;"
$lastTimeFile="LastTimeRecId.txt"
$dataBackupDest="D:\Temp\data"
$archiveBackupDest="D:\Temp\archive"

#最新のアーカイブログ№を取得する
function GetLatestRecId(){
    param($con)

    $latestLogNo = 'select trim(max(recid)) as RECID from v$archived_log'

    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($latestLogNo, $con)
    $reader = $cmd.ExecuteReader()
    [void]$reader.read()
    $reader[0]
}

#前回実行時のアーカイブログ№を取得する
function GetLastTimeRecId(){
    param($con)
    
    if (Test-Path $lastTimeFile){
        Get-Content $lastTimeFile
    }else{
        GetLatestRecId $con
    }
}

#表領域をバックアップモードに変更
function BeginBackup(){
    param($tablespaceName)
    $sqlStr = "alter tablespace {0} begin backup" -F $tablespaceName
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sqlStr, $con)
    [void]$cmd.ExecuteNonQuery()
}

#表領域を通常モードに変更
function EndBackup(){
    param($tablespaceName)
    $sqlStr = "alter tablespace {0} end backup" -F $tablespaceName
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sqlStr, $con)
    [void]$cmd.ExecuteNonQuery()
}

#データファイルのバックアップ
function DataFileBackup(){
    param($con)

    $tablespaceList = 'select vt.name as tablespace_name, vd.name as file_name, vb.status,vb.change#, vb.time
        from v$backup vb ,v$datafile vd ,v$tablespace vt
        where vb.file#=vd.file#
        and vd.ts#=vt.ts# '

    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($tablespaceList, $con)
    $reader = $cmd.ExecuteReader()

    while ( $reader.read() )
    {
        Write-Host ("  {0, -10} - {1}" -F $reader[0], $reader[1])

        #表領域をバックアップモードに変更
        BeginBackup $reader[0]

        #表領域のバックアップ
        Copy-Item $reader[1] -Destination $dataBackupDest -Force
        Write-Host "     Done"

        #表領域を通常モードに変更
        EndBackup $reader[0]
    }
}

#アーカイブログの出力
function ArchiveLog(){
    param($con)
    $sql = 'alter system archive log current'
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql, $con)
    [void]$cmd.ExecuteNonQuery()
}

#アーカイブログのバックアップ
function BackupArchiveLog(){
    param($con, $startRecNo, $endRecNo)

    $sqlStr = 'select recid, name from v$archived_log where recid between {0} and {1}' -F $startRecNo, $endRecNo
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sqlStr, $con)
    $reader = $cmd.ExecuteReader()

    while ( $reader.read() )
    {
        Write-Host ("  {0, 6} - {1}" -F $reader[0], $reader[1])
        Copy-Item $reader[1] -Destination $archiveBackupDest -Force
    }
}

function Main(){
    $con = New-Object Oracle.DataAccess.Client.OracleConnection($conStr)
    $con.Open()

    Write-Host "バックアップ前のログ№取得"
    $startRecNo = (GetLastTimeRecId $con)

    Write-Host "データファイルバックアップ"
    DataFileBackup $con

    Write-Host "アーカイブログ出力"
    ArchiveLog $con

    Write-Host "バックアップ後のログ№取得"
    $endRecNo = (GetLatestRecId $con)

    Write-Host "アーカイブログのバックアップ"
    BackupArchiveLog $con $startRecNo $endRecNo

    Write-Host "次回実行に備えて、最終アーカイブログ№（$endRecNo）をファイル（$lastTimeFile）に書き出し"
    $endRecNo | Out-File $lastTimeFile -Encoding default

    $con.Close()
}


main

trap {
    'trap exception';
    break
}