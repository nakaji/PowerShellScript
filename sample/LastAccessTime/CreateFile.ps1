
function GetFileList {
param ($path, $recurse)
    if ($recurse) {
        Get-ChildItem $path -File -Recurse
    }
    else {
        Get-ChildItem $path -File
    }
}

function GetLastAccessTime {
param ($path, $recurse)
    GetFileList $path $recurse | %{
        if ($lastAccessTime -lt $_.LastWriteTime) {
            $lastAccessTime = $_.LastWriteTime
        }
    }
    $lastAccessTime
}

function CreateFile {
param($fileName, $searchDir, $recurse)

    if (-not(Test-Path $searchDir)) {
        throw "�f�B���N�g�������݂��܂���"
    }

    $fileList = GetFileList $searchDir $recurse
    if ($fileList -eq $null) {
        throw "�w�肳�ꂽ�f�B���N�g���Ƀt�@�C�������݂��܂���"
    }
    
    $time = GetLastAccessTime $searchDir $recurse
    $time.ToString("yyyyMMdd-HHmmss") | Out-File $fileName -Encoding default
}
