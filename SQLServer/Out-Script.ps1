# データベースオブジェクトのスクリプトを出力する
param($serverName, $databaseName, $objectType, $scriptFileName)

$objectTypes=@("Tables", "StoredProcedures", "Views", "Synonyms", "UserDefinedTypes", "UserDefinedFunctions", "Triggers")

function ShowUsage() {
    Write-Host "Usage: Out-Script ServerName DatabaseName ObjectType ScriptFileName"
    Write-Host "    ObjectType : $objectTypes"
}

function ArgCheck() {
    if (($serverName -eq $Null) -or ($databaseName -eq $Null) -or ($objectType -eq $Null) -or ($scriptFileName -eq $Null)) {
        Write-Host "Invalid Arguments!"
        ShowUsage
        exit
    }

    if ( -not ($objectTypes -contains $objectType)) {
        Write-Host "Invalid ObjectType!"
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
$db = $server.Databases[$databaseName]

$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
#出力するスクリプトの設定
$scripter.Options.FileName = $scriptFileName      #出力先ファイル
$scripter.Options.Indexes = $true                 #インデックスを含める
$scripter.Options.ClusteredIndexes = $true        #クラスター化インデックスを含める
$scripter.Options.WithDependencies = $false       #依存オブジェクトを含めない
$scripter.Options.DriAll = $false                 #参照整合性の出力を含めない
$scripter.Options.ToFileOnly = $true              #コンソール出力しない
$scripter.Options.Triggers = $true                #トリガーを含める
$scripter.Options.AnsiPadding = $true             #
$scripter.Options.AppendToFile = $true            #ファイルに追記する
$scripter.Options.IncludeHeaders = $true          #生成日時などの情報を含むヘッダーを出力する
$scripter.Options.ExtendedProperties = $true      #拡張プロパティを含める

#出力対象のオブジェクトを取得
$objects = [Microsoft.SqlServer.Management.Smo.SqlSmoObject[]]$db."$objectType" | ?{ -not $_.IsSystemObject }

# ===== Drop文を出力 =====
#データベース選択のコマンドを出力
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $true
$scripter.Options.IncludeIfNotExists = $true
$scripter.Script($objects)

 

# ===== Create文を出力 =====
#データベース選択のコマンドを出力
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $false
$scripter.Options.IncludeIfNotExists = $false
$scripter.Script($objects)
