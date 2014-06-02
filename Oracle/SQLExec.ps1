#
# sql�X�N���v�g�𕡐��̊��ňꊇ���s���邽�߂̃X�N���v�g
#   ���w���SQLExec.ps1.config�ōs��
#   �X�N���v�g�Ɠ����f�B���N�g����sql�f�B���N�g�����̃X�N���v�g�����s����
#   ���s���O�̓X�N���v�g�Ɠ����f�B���N�g����log�f�B���N�g���ɏo�͂���

$baseDir=Split-Path $MyInvocation.MyCommand.Path
$scriptName=Split-Path $MyInvocation.MyCommand.Path -Leaf

$connStrings=Get-Content ("$baseDir\$scriptName.config")
$scriptFiles=Get-ChildItem "$baseDir\sql"

"���Ώۊ�"
$connStrings
"���ΏۃX�N���v�g"
$scriptFiles | %{$_.Name}
"���s����ɂ�Enter�L�[�������Ă������� . . ."
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
