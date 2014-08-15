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

    It "�w�肳�ꂽ�ꏊ�����݂��Ȃ��ꍇ�͗�O" {
        {CreateFile "$TestDrive\result.txt" "$TestDrive\notexists" $true} | Should Throw "�f�B���N�g�������݂��܂���"
    }
    
    It "�w�肳�ꂽ�ꏊ�Ƀt�@�C����1�������ꍇ�͗�O" {
        {CreateFile "$TestDrive\out\result.txt" "$TestDrive\data\empty" $true} | Should Throw "�w�肳�ꂽ�f�B���N�g���Ƀt�@�C�������݂��܂���"
    }
    
    It "�w��f�B���N�g���K�w�̂ݑΏۂɂ���ꍇ" {
        CreateFile "$TestDrive\out\result.txt" "$TestDrive\data" $false
        "$TestDrive\out\result.txt" | Should Contain "20140101-0000"
    }

    It "�T�u�f�B���N�g�����Ώۂɂ���ꍇ" {
        CreateFile "$TestDrive\out\result.txt" "$TestDrive\data" $true
        "$TestDrive\out\result.txt" | Should Contain "20140815-2030"
    }

    It "�g���q���w�肷��ꍇ�ɂ���ꍇ" {
        CreateFile "$TestDrive\out\result.txt" "$TestDrive\data\*.txt" $true
        "$TestDrive\out\result.txt" | Should Contain "20140810-2030"
    }
}