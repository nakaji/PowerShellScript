
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
        throw "ディレクトリが存在しません"
    }

    $fileList = GetFileList $searchDir $recurse
    if ($fileList -eq $null) {
        throw "指定されたディレクトリにファイルが存在しません"
    }
    
    $time = GetLastAccessTime $searchDir $recurse
    $time.ToString("yyyyMMdd-HHmmss") | Out-File $fileName -Encoding default
}
