#region a completely empty runspace
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::Create()
$InitialSessionState.LanguageMode = 'Full'
$InitialSessionState.ExecutionPolicy = 'Bypass'

$PowerShell = [powershell]::Create($InitialSessionState)
$PowerShell.Runspace.Name = "Constrained"
[void]$PowerShell.AddScript({
  Write-Output "`e[41mCan you hear me?`e[0m"
})
$Runspace = "" | Select-Object PowerShell,Handle
$Runspace.Handle = $PowerShell.BeginInvoke()
$Runspace.PowerShell = $PowerShell

Write-Output $Runspace.PowerShell.EndInvoke($Runspace.Handle)
$Runspace.PowerShell.Runspace.Close()
$Runspace.PowerShell.Dispose()
$Timer.Stop()
$Timer.Elapsed
#endregion

#region a less completely empty runspace
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::Create()
$InitialSessionState.LanguageMode = 'Full'
$InitialSessionState.ExecutionPolicy = 'Bypass'
$InitialSessionState.ImportPSModule('Microsoft.PowerShell.Utility')

$PowerShell = [powershell]::Create($InitialSessionState)
$PowerShell.Runspace.Name = "Constrained"
[void]$PowerShell.AddScript({
  Write-Output "`e[41mCan you hear me now?`e[0m"
})
$Runspace = "" | Select-Object PowerShell,Handle
$Runspace.Handle = $PowerShell.BeginInvoke()
$Runspace.PowerShell = $PowerShell

Write-Output $Runspace.PowerShell.EndInvoke($Runspace.Handle)
$Runspace.PowerShell.Runspace.Close()
$Runspace.PowerShell.Dispose()
$Timer.Stop()
$Timer.Elapsed
#endregion

#region an unconstrained runspace
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault2()

$PowerShell = [powershell]::Create($InitialSessionState)
$PowerShell.Runspace.Name = "Un-Constrained"
[void]$PowerShell.AddScript({
  Write-Output "`e[41mCan you hear me now?`e[0m"
})
$Runspace = "" | Select-Object PowerShell,Handle
$Runspace.Handle = $PowerShell.BeginInvoke()
$Runspace.PowerShell = $PowerShell

Write-Output $Runspace.PowerShell.EndInvoke($Runspace.Handle)
$Runspace.PowerShell.Runspace.Close()
$Runspace.PowerShell.Dispose()
$Timer.Stop()
$Timer.Elapsed
#endregion