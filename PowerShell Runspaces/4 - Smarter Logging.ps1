#Region Params
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$false)]
  [ValidateRange(1,100)]
  [int]$MaxWorkers = 10
)
#endregion

#region Setup Storage Objects
Clear-Host
$DataToProcess = [System.Collections.Concurrent.ConcurrentStack[Int32]]::new()
$LogEntries = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
$WorkerRunning = [System.Collections.Concurrent.ConcurrentDictionary[int, bool]]::new()
for ($i = 1; $i -le 1000; $i++) {
  $DataToProcess.Push($i)
}
$Runspaces = [System.Collections.Generic.List[Object]]::new()
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,$MaxWorkers)
$RunspacePool.Open()
#endregion

#Create and Start Workers
for ($i = 1; $i -le $MaxWorkers; $i++) {
  $PowerShell = [powershell]::Create()
  $PowerShell.Runspace.Name = "Runspace_$($i)"
  $PowerShell.RunspacePool = $RunspacePool
  [void]$PowerShell.AddScript({
    Param(
      [System.Collections.Concurrent.ConcurrentStack[Int32]]$DataToProcess,
      [System.Collections.Concurrent.ConcurrentQueue[string]]$LogEntries,
      [System.Collections.Concurrent.ConcurrentDictionary[int, bool]]$WorkerRunning,
      [Int32]$index
    )
    $item = $null
    while ($DataToProcess.TryPop([ref]$item)) {
      $LogEntries.Enqueue("Runspace $($index) Grabbed $($item)")
      Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 200)
    }
    $WorkerRunning.TryUpdate($index, $false, $true)
  })
  [void]$PowerShell.AddParameters(@{
    DataToProcess=$DataToProcess;
    LogEntries=$LogEntries;
    WorkerRunning=$WorkerRunning;
    index=$i;
  })
  [void]$WorkerRunning.TryAdd($i, $true)
  $Ps = "" | Select-Object PowerShell,Handle
  $Ps.Handle = $PowerShell.BeginInvoke()
  $Ps.PowerShell = $PowerShell
  [void]$Runspaces.Add($Ps)
}
#endregion

#region Process the Queue while the Worker Threads Run
$ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
$RunningCount = $MaxWorkers
while ($RunningCount -gt 0) {
  $RunningCount = 0
  $StatusString = [System.Text.StringBuilder]::new()
  for ($i = 1; $i -le $MaxWorkers; $i++) {
    if ($WorkerRunning[$i] -eq $true) {
      $RunningCount++ 
      [void]$StatusString.Append("$($i): `e[92mRunning`e[37m ")
    } else {
      [void]$StatusString.Append("$($i): `e[91mStopped`e[37m ")
    }
  }
  Write-Output "`e[0;0HWorker Status:".PadRight($ConsoleWidth - 1)
  Write-Output $StatusString.ToString()
  $item = $null
  while($LogEntries.TryDequeue([ref]$item)) {
    Write-Output $item.PadRight($ConsoleWidth - 1)
  }
  Start-Sleep -Milliseconds 100
}

foreach ($runspace in $Runspaces) {
  [void]$runspace.PowerShell.EndInvoke($runspace.Handle)
  $runspace.PowerShell.Dispose()
}
#endregion