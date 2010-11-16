Param([String]$templateName="TestData\Test.tpl")

function InsertFile([String]$directory, [String]$fileName)
{
    $insertFileName = Join-Path $directory $fileName
    $buf = ""
    if (-not(Test-Path $insertFileName)) {
        Write-Error ("�t�@�C�������݂��܂���F" + $insertFileName)
        return;
    }
    return Get-Content $insertFileName
}

Get-Content $templateName | 
%{
    # �u#<INSERT hoge>�v�̕������uhoge�v�̃t�@�C���̓��e�ɍ����ւ���
    if ($_ -match "^#INSERT<(.+)>.*") {
        #Split-Path $templateName -Parent | InsertFile($_, $matches[1])
        $directory = Split-Path $templateName -Parent
        $buf = InsertFile $directory $matches[1]
        $buf
    } else {
        $_
    }
} | %{
        # �u/*<REPLACE hoge */ piyo /*>*/�v �� �uhoge�v�ɒu��
        ($_ -replace '/\*<REPLACE\s+(.+)\s+\*/\s.+\s/\*>\*/', '$1')
    }


