. PSUnit.Support.ps1


function Assert-That()
{
<# 
.Synopsis 
    Evaluates Assertions in the PSUnit framework based on the Constraint Model
.Description
    Assert-That takes two arguments. The first parameter is the value that gets evaluated.
    The second parameter is the Scriptblock that defines the evaluation expression.
.Example 
    Assert-That -ActualValue $(2 + 2) -Constraint {$ActualValue -eq 4}
.Parameter $ActualValue is the value that gets evaluated.
.Parameter $Constraint is a Scriptblock that defines the expression that evaluates $ActualValue
    The string consisting of all the parameters to pass to App
.ReturnValue 
    Returns $True, if evaluation expression results in a boolean true value.
    Throws Exception, if evaluation expression results in a boolean false value.
    Throws Exception, if evaluation expression results in a non-boolean result.
    Re-throws Exception, if evaluation expression results in an Exception.
.Link 
    about_functions_advanced 
    about_functions_advanced_methods 
    about_functions_advanced_parameters 
.Notes 
NAME:      Assert-That 
AUTHOR:    Klaus Graefensteiner 
LASTEDIT:  07/28/2009 12:12:42
#Requires -Version 2.0 
#> 
    [CmdletBinding()]
    PARAM(
        
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [Alias("A","Actual")]
    $ActualValue,
    
    [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$false)]
    [Alias("C","Lamda")]
    [ScriptBlock] $Constraint
    
    
    )
    Process{
        try
        {
            $Result = & $Constraint
            if( $Result -isnot [bool])
            {
                Write-Debug "Assert-That: Case: `$Result -isnot [bool]"
                $Exception = New-Object -TypeName "PSUnit.Assert.PSUnitAssertEvaluatedToNonBooleanTypeException" -ArgumentList "Assert-That returned type that is not boolean!"
                Write-Debug "Assert-That: Throwing exception: $($Exception.GetType().FullName)"
                throw $Exception
            }
            if ($Result)
            {
                Write-Debug "Assert-That: Case: `$Result -eq `$true"
                $True
            }
            else
            {
                Write-Debug "Assert-That: Case: `$Result -eq `$false"
                $Exception = New-Object -TypeName "PSUnit.Assert.PSUnitAssertEvaluatedToFalseException" -ArgumentList "Assert-That returned false!"
                Write-Debug "Assert-That: Throwing exception: $($Exception.GetType().FullName)"
                throw $Exception
            }
        }
        catch
        {
            Write-Debug "Assert-That: Caught exception: $($_.Exception.GetType().Fullname)"
            $AssertException = New-Object -TypeName "PSUnit.Assert.PSUnitAssertFailedException" -ArgumentList "$($_.Exception.Message)", "$($_.Exception)"
            Write-Debug "Assert-That: Re-throwing exception: $($AssertException.GetType().FullName)"
            throw $AssertException
        }

    }# End Process
}


