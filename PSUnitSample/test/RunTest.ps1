CLS
$ProjectHome = (Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent)
$ProductHome = (Join-Path $ProjectHome "src")
$TestHome = Join-Path $ProjectHome "test"

$env:PSUNIT_HOME = Join-Path $ProjectHome "psunit"
if ( $env:Path -notlike "*$env:PSUNIT_HOME*" ){ $env:Path += ";$env:PSUNIT_HOME" }

PSUnit.Run.ps1 (Join-Path $TestHome "TestSample.ps1")
