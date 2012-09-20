# SQLServerに登録されたジョブのスクリプトを出力する
param($serverName, $scriptFileName)

$databaseName = "msdb"

function ShowUsage() {
    Write-Host "Usage: Out-Script ServerName ScriptFileName"
}

function ArgCheck() {
    if (($serverName -eq $Null) -or ($scriptFileName -eq $Null)) {
        Write-Host "Invalid Arguments!"
        ShowUsage
        exit
    }
}

function OutputSelectDatabaseScript() {
    #データベース選択のコマンドを出力
    Add-Content -Path $scriptFileName -encoding Unicode -Value "USE [$databaseName]"
    Add-Content -Path $scriptFileName -encoding Unicode -Value "GO"
    Add-Content -Path $scriptFileName -encoding Unicode -Value ""
}

#アセンブリの読み込み
[void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

#引数チェック
ArgCheck

#追記するので既にファイルがある場合は出力ファイルを削除する
if (Test-Path $scriptFileName) {
    Remove-Item $scriptFileName
}

$server = New-Object Microsoft.SqlServer.Management.Smo.Server($serverName)

$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
#出力するスクリプトの設定
$scripter.Options.FileName = $scriptFileName      #出力先ファイル
$scripter.Options.WithDependencies = $false       #依存オブジェクトを含めない
$scripter.Options.ToFileOnly = $true              #コンソール出力しない
$scripter.Options.AppendToFile = $true            #ファイルに追記する
$scripter.Options.IncludeHeaders = $true          #生成日時などの情報を含むヘッダーを出力する

# ===== Drop文を出力 =====
#データベース選択のコマンドを出力
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $true
$scripter.Options.IncludeIfNotExists = $true
[Microsoft.SqlServer.Management.Smo.SqlSmoObject[]]$server.JobServer.Jobs | 
%{
    $scripter.Script($_)
    Add-Content -Path $scriptFileName -encoding Unicode -Value ""
}

# ===== Create文を出力 =====
#データベース選択のコマンドを出力
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $false
$scripter.Options.IncludeIfNotExists = $false
[Microsoft.SqlServer.Management.Smo.SqlSmoObject[]]$server.JobServer.Jobs | 
%{
    $scripter.Script($_)
    Add-Content -Path $scriptFileName -encoding Unicode -Value ""
}
