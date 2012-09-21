# SQLServer�ɓo�^���ꂽ�W���u�̃X�N���v�g���o�͂���
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
    #�f�[�^�x�[�X�I���̃R�}���h���o��
    Add-Content -Path $scriptFileName -encoding Unicode -Value "USE [$databaseName]"
    Add-Content -Path $scriptFileName -encoding Unicode -Value "GO"
    Add-Content -Path $scriptFileName -encoding Unicode -Value ""
}

#�A�Z���u���̓ǂݍ���
[void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

#�����`�F�b�N
ArgCheck

#�ǋL����̂Ŋ��Ƀt�@�C��������ꍇ�͏o�̓t�@�C�����폜����
if (Test-Path $scriptFileName) {
    Remove-Item $scriptFileName
}

$server = New-Object Microsoft.SqlServer.Management.Smo.Server($serverName)

$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
#�o�͂���X�N���v�g�̐ݒ�
$scripter.Options.FileName = $scriptFileName      #�o�͐�t�@�C��
$scripter.Options.WithDependencies = $false       #�ˑ��I�u�W�F�N�g���܂߂Ȃ�
$scripter.Options.ToFileOnly = $true              #�R���\�[���o�͂��Ȃ�
$scripter.Options.AppendToFile = $true            #�t�@�C���ɒǋL����
$scripter.Options.IncludeHeaders = $true          #���������Ȃǂ̏����܂ރw�b�_�[���o�͂���

#�o�͑Ώۂ̃I�u�W�F�N�g���擾
$jobs = [Microsoft.SqlServer.Management.Smo.SqlSmoObject[]]$server.JobServer.Jobs

# ===== Drop�����o�� =====
#�f�[�^�x�[�X�I���̃R�}���h���o��
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $true
$scripter.Options.IncludeIfNotExists = $true
$scripter.Script($jobs)

# ===== Create�����o�� =====
#�f�[�^�x�[�X�I���̃R�}���h���o��
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $false
$scripter.Options.IncludeIfNotExists = $false
$scripter.Script($jobs)
