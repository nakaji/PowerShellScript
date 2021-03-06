function DefaultException()
{
    return $(new-object -TypeName "System.InvalidOperationException")
}

function Set-DebugMode()
{
    $Global:DebugPreference = "Continue"
    set-strictmode -version Latest
}

function Set-ProductionMode()
{
    $Global:DebugPreference = "SilentlyContinue"
    set-strictmode -Off
}

function Compile-Code()
{
    param (
        [string[]] $code       = $(throw "The parameter -code is required.")
      , [string[]] $references = @()
      , [switch]   $asString   = $false
      , [switch]   $showOutput = $false
      , [switch]   $csharp     = $true
      , [switch]   $vb         = $false
    )
    
    $options    = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.String]";
    $options.Add( "CompilerVersion", "v3.5")
    
    if ( $vb ) {
        $provider = New-Object Microsoft.VisualBasic.VBCodeProvider $options
    } else {
        $provider = New-Object Microsoft.CSharp.CSharpCodeProvider $options
    }
    
    $parameters = New-Object System.CodeDom.Compiler.CompilerParameters
    
    @( "mscorlib.dll", "System.dll", "System.Core.dll", "System.Xml.dll", ([System.Reflection.Assembly]::GetAssembly( [PSObject] ).Location) ) + $references | Sort -unique |% { $parameters.ReferencedAssemblies.Add( $_ ) } | Out-Null
    
    $parameters.GenerateExecutable = $false
    $parameters.GenerateInMemory   = !$asString
    $parameters.CompilerOptions    = "/optimize"
    
    if ( $asString ) {
        $parameters.OutputAssembly = [System.IO.Path]::GetTempFileName()
    }
    
    $results = $provider.CompileAssemblyFromSource( $parameters, $code )
    
    if ( $results.Errors.Count -gt 0 ) {
        if ( $output ) {
            $results.Output |% { Write-Output $_ }
        } else {
            $results.Errors |% { Write-Error $_.ToString() }
        }
    } else {
        if ( $asString ) {
            $content = [System.IO.File]::ReadAllBytes( $parameters.OutputAssembly )
            $content = [Convert]::ToBase64String( $content )
            
            [System.IO.File]::Delete( $parameters.OutputAssembly );
            
            return $content
        } else {
            return $results.CompiledAssembly
        }        
    }
}


$PSUnitAssertFailedExceptionCode =
@"
    using System;

    namespace PSUnit.Assert
    {
        public class PSUnitAssertFailedException : System.Exception
        {
            public PSUnitAssertFailedException()
            {
            }
            public PSUnitAssertFailedException(string message) : base(message)
            {
            }
            public PSUnitAssertFailedException(string message, Exception innerException)
            : base(message, innerException)
            {
            }
        }
    }
"@

$PSUnitAssertEvaluatedToFalseExceptionCode =
@"
    using System;

    namespace PSUnit.Assert
    {
        public class PSUnitAssertEvaluatedToFalseException : System.Exception
        {
            public PSUnitAssertEvaluatedToFalseException()
            {
            }
            public PSUnitAssertEvaluatedToFalseException(string message) : base(message)
            {
            }
            public PSUnitAssertEvaluatedToFalseException(string message, Exception innerException)
                : base(message, innerException)
            {
            }
        }
    }
"@

$PSUnitAssertEvaluatedToNonBooleanTypeExceptionCode=
@"
    using System;

    namespace PSUnit.Assert
    {
        public class PSUnitAssertEvaluatedToNonBooleanTypeException : System.Exception
        {
            public PSUnitAssertEvaluatedToNonBooleanTypeException()
            {
            }
            public PSUnitAssertEvaluatedToNonBooleanTypeException(string message) : base(message)
            {
            }
            public PSUnitAssertEvaluatedToNonBooleanTypeException(string message, Exception innerException)
            : base(message, innerException)
            {
            }
        }
    }
"@

function Build-PSUnitAssertFailedExceptionType()
{
    $Result = Compile-Code -csharp -code $PSUnitAssertFailedExceptionCode
    Write-Debug "Build-PSUnitAssertFailedExceptionType: $Result"
}

function Build-PSUnitAssertEvaluatedToFalseExceptionType()
{
    $Result = Compile-Code -csharp -code $PSUnitAssertEvaluatedToFalseExceptionCode
    Write-Debug "Build-PSUnitAssertEvaluatedToFalseExceptionType: $Result"

}

function Build-PSUnitAssertEvaluatedToNonBooleanTypeExceptionType()
{
    $Result = Compile-Code -csharp -code $PSUnitAssertEvaluatedToNonBooleanTypeExceptionCode
    Write-Debug "Build-PSUnitAssertEvaluatedToNonBooleanTypeExceptionType $Result"
}

Build-PSUnitAssertFailedExceptionType
Build-PSUnitAssertEvaluatedToFalseExceptionType
Build-PSUnitAssertEvaluatedToNonBooleanTypeExceptionType

function Get-ErrorRecord([string] $InnerExceptionTypeName, [string] $OuterExceptionTypeName, [string] $OuterExceptionMessage)
{
    $ErrorRecord = $Null
    try
    {
        try
        {
            Throw New-Object -TypeName $InnerExceptionTypeName
        }
        catch
        {
            $OuterException = New-Object -TypeName $OuterExceptionTypeName -ArgumentList $OuterExceptionMessage, $($_.Exception)
            Throw $OuterException
        }
    }
    catch
    {
        $ErrorRecord = $_
    }
    return $ErrorRecord
}

function Format-ErrorRecord([System.Management.Automation.ErrorRecord] $Record)
{
    $StringOutput = ""
    if ($Record.FullyQualifiedErrorId -ne "NativeCommandErrorMessage" -and $ErrorView -ne "CategoryView") 
    {
        $myinv = $Record.InvocationInfo
        if($myinv.MyCommand)
        {
            switch -regex ($myinv.MyCommand.CommandType)
            {
                "ExternalScript"
                {
                    if ($myinv.MyCommand.Path)
                    {
                        $StringOutput += $myinv.MyCommand.Path + " : ";
                    }
                    break;
                }
                "Script"
                {
                    if ($myinv.MyCommand.ScriptBlock)
                    {
                        $StringOutput += $myinv.MyCommand.ScriptBlock.ToString() + " : ";
                    }
                    break;
                }
                default
                {
                    if ($myinv.MyCommand.Name)
                    {
                        $StringOutput += $myinv.MyCommand.Name + " : "; break;
                    }
                }
            }
        }
    }
    if ($Record.FullyQualifiedErrorId -eq "NativeCommandErrorMessage") 
    {
        $StringOutput += $Record.Exception.Message   
    }
    else
    {
        if ($Record.InvocationInfo) 
        {
            $posmsg = $Record.InvocationInfo.PositionMessage
        } 
        else 
        {
            $posmsg = ""
        }
    				    
   		if ($Record.PSMessageDetails) 
        {
            $posmsg = " : " +  $Record.PSMessageDetails + $posmsg 
		}

        $indent = 4
        $width = $host.UI.RawUI.BufferSize.Width - $indent - 2

        $indentString = "+ CategoryInfo          : " + $Record.CategoryInfo
        $posmsg += "`n"
        foreach($line in @($indentString -split "(.{$width})")) { if($line) { $posmsg += (" " * $indent + $line) } }

        $indentString = "+ FullyQualifiedErrorId : " + $Record.FullyQualifiedErrorId
        $posmsg += "`n"
        foreach($line in @($indentString -split "(.{$width})")) { if($line) { $posmsg += (" " * $indent + $line) } }

        if ($ErrorView -eq "CategoryView") 
        {
            $StringOutput += $Record.CategoryInfo.GetMessage()
        }
        elseif (! $Record.ErrorDetails -or ! $Record.ErrorDetails.Message) 
        {
            $StringOutput += $Record.Exception.Message + $posmsg + "`n "
        } 
        else 
        {
            $StringOutput += $Record.ErrorDetails.Message + $posmsg
        }
    }
    return $StringOutput
}

function Encode-Html([string] $StringToEncode)
{
    $AssemblyLoaded = $false
    try
    {
        $SystemWebAssembly = [Reflection.Assembly]::LoadFrom("C:\windows\assembly\GAC_64\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll")
        $AssemblyLoaded = $true
    }
    catch
    {
        Write-Debug "C:\windows\assembly\GAC_64\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll not found!"
    }
    
    if(!$AssemblyLoaded)
    {
        try
        {
            $SystemWebAssembly = [Reflection.Assembly]::LoadFrom("C:\windows\assembly\GAC_32\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll")
        }
        catch
        {
            Write-Debug "C:\windows\assembly\GAC_32\System.Web\2.0.0.0__b03f5f7f11d50a3a\System.Web.dll not found!"
        }
    }
    $HtmlEncodedErrorRecordString = [System.Web.HttpUtility]::HtmlEncode($StringToEncode)
    return $HtmlEncodedErrorRecordString
}
