$Credential = Get-Credential
#$ConnectionInfo = [System.Management.Automation.Runspaces.WSManConnectionInfo]::New($false, 'localhost', 5985, 'wsman', 'http://schemas.microsoft.com/powershell/Microsoft.PowerShell', $Credential)
$ConnectionInfo = [System.Management.Automation.Runspaces.WSManConnectionInfo]::New('http://localhost:5985/wsman', 'http://schemas.microsoft.com/powershell/Microsoft.PowerShell', $Credential)
$Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($ConnectionInfo)
$Runspace.Open()

$PowerShell = [powershell]::Create()
$PowerShell.Runspace = $Runspace
$PowerShell.Runspace.Name = "$($Credential.UserName)@localhost"
[void]$PowerShell.AddScript({
  Write-Output "RS: Testing Path: Good Folder"
  Write-Output (Test-Path -Path "C:\Test\Good")
  Write-Output "RS: Testing Path: Bad Folder"
  Write-Output (Test-Path -Path "C:\Test\Bad")
})

$Thread = "" | Select-Object PowerShell,Handle
$Thread.Handle = $PowerShell.BeginInvoke()
$Thread.PowerShell = $PowerShell

Write-Output "Testing Path: Good Folder"
Write-Output (Test-Path -Path "C:\Test\Good")
Write-Output "Testing Path: Bad Folder"
Write-Output (Test-Path -Path "C:\Test\Bad")

Write-Output $Thread.PowerShell.EndInvoke($Thread.Handle)
$Thread.PowerShell.Runspace.Close()
$Thread.PowerShell.Dispose()


