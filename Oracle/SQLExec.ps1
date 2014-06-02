#
# sqlスクリプトを複数の環境で一括実行するためのスクリプト
#   環境指定はSQLExec.ps1.configで行う
#   スクリプトと同じディレクトリのsqlディレクトリ内のスクリプトを実行する
#   実行ログはスクリプトと同じディレクトリのlogディレクトリに出力する

$baseDir=Split-Path $MyInvocation.MyCommand.Path
$scriptName=Split-Path $MyInvocation.MyCommand.Path -Leaf

$connStrings=Get-Content ("$baseDir\$scriptName.config")
$scriptFiles=Get-ChildItem "$baseDir\sql"

"■対象環境"
$connStrings
"■対象スクリプト"
$scriptFiles | %{$_.Name}
"続行するにはEnterキーを押してください . . ."
Read-Host

$logDir = "$baseDir\log\"

if (-not(Test-Path $logDir )) { mkdir $logDir | Out-Null }

$connStrings | %{
    $connStr = $_
    $scriptFiles | %{
        $script = Get-Content $_.FullName

        $logName = $logDir + ($connStr -replace "/","-")+"_"+$_

        $script | sqlplus -S $connStr | Out-File $logName -Encoding default
    }
}
