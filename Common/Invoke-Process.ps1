function global:Invoke-Process
{
    param([string]$cmd , [string]$arg)

    $process = New-Object "System.Diagnostics.Process";
    $process.StartInfo.FileName = $cmd;
    $process.StartInfo.Arguments = $arg;
    $process.StartInfo.WorkingDirectory = (get-item ".").FullName
    $process.StartInfo.RedirectStandardOutput = $True;
    $process.StartInfo.RedirectStandardError = $True;
    $process.StartInfo.UseShellExecute = $False;

    $process.Start() | Out-Null;
    $process.WaitForExit();

    return @{
        "ExitCode" = $process.ExitCode;
        "StandardOutput" = $process.StandardOutput.ReadToEnd();
        "StandardError" = $process.StandardError.ReadToEnd();
    }
}