#ナオキにASP.NET（仮） : PowerShell を使って、複数台の端末上に同様の設定でパフォーマンスチェックの簡略化を実現
#  http://cs.gogo-asp.net/blogs/naoki/archive/2011/12/21/PowerShell-_92307F4F63306630013007897065F0536E30EF7A2B670A4E6B300C54D8696E302D8A9A5B6730D130D530A930FC30DE30F330B930C130A730C330AF306E30217C6575165392309F5BFE73_.aspx
#
#IDataCollectorSet::Commit method (Windows)
#  http://msdn.microsoft.com/en-us/library/aa371965(v=vs.85).aspx

$serverList=@("localhost","hogehoge")

$basePath = (Split-Path $MyInvocation.MyCommand.Path)

$datacollectorset = New-Object -COM Pla.DataCollectorSet
$xml = Get-Content "$basePath\Perflog.xml"
$datacollectorset.SetXml($xml)

$serverList | %{
    $datacollectorset.Commit("パフォーマンスチェック" , $_ , 0x0003) | Out-Null
    $datacollectorset.Query("パフォーマンスチェック", $_)
    #$datacollectorset.Start($false)
}

