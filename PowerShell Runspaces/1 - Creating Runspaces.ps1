#region Create a single runspace
$Runspace = [powershell]::Create()
[void]$Runspace.AddScript({
  Param(
    $InputObject
  )
  Write-Output $InputObject
})
[void]$Runspace.AddParameters(@{
  InputObject = "Hello World!"
})
$Handle = $Runspace.BeginInvoke()
$Output = $Runspace.EndInvoke($Handle)
$Runspace.Dispose()
#EndRegion

#region What about the output?
Write-Output $Output
#endregion

#region Create a runspace pool
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,10)
$RunspacePool.Open()
$Runspaces = [System.Collections.Generic.List[Object]]::new()
for ($i = 0; $i -lt 100; $i++) {
  $PowerShell = [powershell]::Create()
  $PowerShell.Runspace.Name = "Runspace_$($i)"
  $PowerShell.RunspacePool = $RunspacePool
  [void]$PowerShell.AddScript({
    Param(
      $InputObject
    )
    Write-Output $InputObject
  })
  [void]$PowerShell.AddParameters(@{
    InputObject = $i
  })
  $Handle = $PowerShell.BeginInvoke()
  [void]$Runspaces.Add(@{
    PowerShell = $PowerShell
    Handle = $Handle
  })
}

foreach ($Rs in $Runspaces) {
  Write-Output $Rs.PowerShell.EndInvoke($Rs.Handle)
  $Rs.PowerShell.Dispose()
}
#endregion