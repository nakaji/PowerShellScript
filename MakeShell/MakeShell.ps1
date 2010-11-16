Param([String]$templateName="TestData\Test.tpl")

function InsertFile([String]$directory, [String]$fileName)
{
    $insertFileName = Join-Path $directory $fileName
    $buf = ""
    if (-not(Test-Path $insertFileName)) {
        Write-Error ("ファイルが存在しません：" + $insertFileName)
        return;
    }
    return Get-Content $insertFileName
}

Get-Content $templateName | 
%{
    # 「#<INSERT hoge>」の部分を「hoge」のファイルの内容に差し替える
    if ($_ -match "^#INSERT<(.+)>.*") {
        #Split-Path $templateName -Parent | InsertFile($_, $matches[1])
        $directory = Split-Path $templateName -Parent
        $buf = InsertFile $directory $matches[1]
        $buf
    } else {
        $_
    }
} | %{
        # 「/*<REPLACE hoge */ piyo /*>*/」 を 「hoge」に置換
        ($_ -replace '/\*<REPLACE\s+(.+)\s+\*/\s.+\s/\*>\*/', '$1')
    }


