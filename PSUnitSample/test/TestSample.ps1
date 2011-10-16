CLS
. (Join-Path -Path $env:PSUNIT_HOME -ChildPath "PSUnit.ps1")
. (Join-Path -Path $ProductHome "FizzBuzzFunction.ps1")

Function Test.Normal()
{
    $actusl = FizzBuzz(1)
    Assert-That -ActualValue $actusl -Constraint { $ActualValue -eq 1 }

    $actusl = FizzBuzz(2)
    Assert-That -ActualValue $actusl -Constraint { $ActualValue -eq 2 }
}

Function Test.Three()
{
    $actusl = FizzBuzz(3)
    Assert-That -ActualValue $actusl -Constraint { $ActualValue -eq "Fizz" }
}

Function Test.Five()
{
    $actusl = FizzBuzz(5)
    Assert-That -ActualValue $actusl -Constraint { $ActualValue -eq "Buzz" }
}

Function Test.Six()
{
    $actusl = FizzBuzz(6)
    Assert-That -ActualValue $actusl -Constraint { $ActualValue -eq "Fizz" }
}

Function Test.Ten()
{
    $actusl = FizzBuzz(10)
    Assert-That -ActualValue $actusl -Constraint { $ActualValue -eq "Buzz" }
}

Function Test.Fifteen()
{
    $actusl = FizzBuzz(15)
    Assert-That -ActualValue $actusl -Constraint { $ActualValue -eq "FizzBuzz" }
}