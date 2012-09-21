# �f�[�^�x�[�X�I�u�W�F�N�g�̃X�N���v�g���o�͂���
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
$db = $server.Databases[$databaseName]

$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
#�o�͂���X�N���v�g�̐ݒ�
$scripter.Options.FileName = $scriptFileName      #�o�͐�t�@�C��
$scripter.Options.Indexes = $true                 #�C���f�b�N�X���܂߂�
$scripter.Options.ClusteredIndexes = $true        #�N���X�^�[���C���f�b�N�X���܂߂�
$scripter.Options.WithDependencies = $false       #�ˑ��I�u�W�F�N�g���܂߂Ȃ�
$scripter.Options.DriAll = $false                 #�Q�Ɛ������̏o�͂��܂߂Ȃ�
$scripter.Options.ToFileOnly = $true              #�R���\�[���o�͂��Ȃ�
$scripter.Options.Triggers = $true                #�g���K�[���܂߂�
$scripter.Options.AnsiPadding = $true             #
$scripter.Options.AppendToFile = $true            #�t�@�C���ɒǋL����
$scripter.Options.IncludeHeaders = $true          #���������Ȃǂ̏����܂ރw�b�_�[���o�͂���
$scripter.Options.ExtendedProperties = $true      #�g���v���p�e�B���܂߂�

#�o�͑Ώۂ̃I�u�W�F�N�g���擾
$objects = [Microsoft.SqlServer.Management.Smo.SqlSmoObject[]]$db."$objectType" | ?{ -not $_.IsSystemObject }

# ===== Drop�����o�� =====
#�f�[�^�x�[�X�I���̃R�}���h���o��
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $true
$scripter.Options.IncludeIfNotExists = $true
$scripter.Script($objects)

 

# ===== Create�����o�� =====
#�f�[�^�x�[�X�I���̃R�}���h���o��
OutputSelectDatabaseScript

$scripter.Options.ScriptDrops = $false
$scripter.Options.IncludeIfNotExists = $false
$scripter.Script($objects)
