#Run unit tests in current script file
function Global:Run-CurrentTestFile
{
    PSUnit.Run.ps1 -PSUnitTestFile $($psISE.CurrentFile.FullPath) -ShowReportInBrowser
}

$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Clear()
# Add an Add-ons menu with an accessor.
# Note the use of “_”  as opposed to the “&” for mapping to the fast key letter for the menu item.
$PSUnitMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("_PSUnit",$null, $null) 
$ExecuteTestSubMenu = $PSUnitMenu.SubMenus.Add("E_xecute Unit Tests", {Run-CurrentTestFile}, 'Ctrl+SHIFT+X')