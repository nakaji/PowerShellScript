$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function CreateTestFile {
param ($fileName, $time)
    Setup -File $fileName
    Set-ItemProperty "$TestDrive\$fileName" -name LastWriteTime -value $(Get-Date $time)
}

Describe "CreateFile" {
    Setup -Dir "out" "copntent"
    Setup -Dir "data" "copntent"
    Setup -Dir "data\sub" "copntent"
    Setup -Dir "data\empty" "copntent"
    CreateTestFile "data\1.txt" "2014/01/01 00:00:00"
    CreateTestFile "data\sub\2.txt" "2014/08/10 20:30:40"
    CreateTestFile "data\sub\3.log" "2014/08/15 20:30:40"

    It "指定された場所が存在しない場合は例外" {
        {CreateFile "$TestDrive\result.txt" "$TestDrive\notexists" $true} | Should Throw "ディレクトリが存在しません"
    }
    
    It "指定された場所にファイルが1つも無い場合は例外" {
        {CreateFile "$TestDrive\out\result.txt" "$TestDrive\data\empty" $true} | Should Throw "指定されたディレクトリにファイルが存在しません"
    }
    
    It "指定ディレクトリ階層のみ対象にする場合" {
        CreateFile "$TestDrive\out\result.txt" "$TestDrive\data" $false
        "$TestDrive\out\result.txt" | Should Contain "20140101-0000"
    }

    It "サブディレクトリも対象にする場合" {
        CreateFile "$TestDrive\out\result.txt" "$TestDrive\data" $true
        "$TestDrive\out\result.txt" | Should Contain "20140815-2030"
    }

    It "拡張子を指定する場合にする場合" {
        CreateFile "$TestDrive\out\result.txt" "$TestDrive\data\*.txt" $true
        "$TestDrive\out\result.txt" | Should Contain "20140810-2030"
    }
}