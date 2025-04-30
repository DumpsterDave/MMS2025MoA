#region Unsafe Collections
$UnsafeArrayList = [System.Collections.ArrayList]::New(1..2)
$UnsafeHashTable = [System.Collections.Hashtable]::New(@{0=1})
[Int32]$UnsafeInt = 100

$RunspacePool = [runspacefactory]::CreateRunspacePool(1,10)
$RunspacePool.Open()

$Runspaces = [System.Collections.Generic.List[Object]]::new()

for ($i = 0; $i -lt 100; $i++) {
  $PowerShell = [powershell]::Create()
  $PowerShell.Runspace.Name = "Runspace_$($i)"
  $Powershell.RunspacePool = $RunspacePool
  [void]$PowerShell.AddScript({
    Param(
      $ArrayList,
      $HashTable,
      $int
    )
    Start-Sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 20)
    $ArrayList[0]++
    $HashTable[0]++
    $int++
  })
  [void]$PowerShell.AddParameters(@{
    ArrayList=$UnsafeArrayList;
    HashTable=$UnsafeHashTable;
    int=$UnsafeInt
    index=$i;
  })

  $Ps = "" | Select-Object PowerShell,Handle
  $Ps.Handle = $PowerShell.BeginInvoke()
  $Ps.PowerShell = $PowerShell
  
  [void]$Runspaces.Add($Ps)
}

foreach ($runspace in $Runspaces) {
  $Output = $runspace.PowerShell.EndInvoke($runspace.Handle)
  $runspace.PowerShell.Dispose()
}
#endregion

#region Unsafe Results
$UnsafeArrayList
$UnsafeHashTable
$UnsafeInt
#endregion

#region Safe Collections
$SafeArrayList = [System.Collections.ArrayList]::Synchronized(1..2)
$SafeHashTable = [System.Collections.Hashtable]::Synchronized(@{0=1})
[Int32]$SafeInt = 100

$RunspacePool = [runspacefactory]::CreateRunspacePool(1,10)
$RunspacePool.Open()

$Runspaces = [System.Collections.Generic.List[Object]]::new()

for ($i = 0; $i -lt 100; $i++) {
  $PowerShell = [powershell]::Create()
  $PowerShell.Runspace.Name = "Runspace_$($i)"
  $Powershell.RunspacePool = $RunspacePool
  [void]$PowerShell.AddScript({
    Param(
      $ArrayList,
      $HashTable,
      $int
    )
    Start-Sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 20)
    $ArrayList[0]++
    $HashTable[0]++
    $int++
  })
  [void]$PowerShell.AddParameters(@{
    ArrayList=$SafeArrayList;
    HashTable=$SafeHashTable;
    int=$SafeInt
    index=$i;
  })

  $Ps = "" | Select-Object PowerShell,Handle
  $Ps.Handle = $PowerShell.BeginInvoke()
  $Ps.PowerShell = $PowerShell
  
  [void]$Runspaces.Add($Ps)
}

foreach ($runspace in $Runspaces) {
  $Output = $runspace.PowerShell.EndInvoke($runspace.Handle)
  $runspace.PowerShell.Dispose()
}
#endregion

#region Safe Results
$SafeArrayList
$SafeHashTable
$SafeInt
#endregion

#region Actually Safe Collections
$SafeArrayList = [System.Collections.ArrayList]::Synchronized(1..2)
$SafeHashTable = [System.Collections.Hashtable]::Synchronized(@{0=1})
[Int32]$SafeInt = 100

$RunspacePool = [runspacefactory]::CreateRunspacePool(1,10)
$RunspacePool.Open()

$Runspaces = [System.Collections.Generic.List[Object]]::new()

for ($i = 0; $i -lt 100; $i++) {
  $PowerShell = [powershell]::Create()
  $PowerShell.Runspace.Name = "Runspace_$($i)"
  $Powershell.RunspacePool = $RunspacePool
  [void]$PowerShell.AddScript({
    Param(
      $ArrayList,
      $HashTable,
      $int
    )
    [System.Threading.Monitor]::Enter($ArrayList)
    [System.Threading.Monitor]::Enter($HashTable)
    Start-Sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 20)
    $ArrayList[0]++
    $HashTable[0]++
    [System.Threading.Monitor]::Exit($HashTable)
    [System.Threading.Monitor]::Exit($ArrayList)
    $int++
  })
  [void]$PowerShell.AddParameters(@{
    ArrayList=$SafeArrayList;
    HashTable=$SafeHashTable;
    int=$SafeInt
    index=$i;
  })

  $Ps = "" | Select-Object PowerShell,Handle
  $Ps.Handle = $PowerShell.BeginInvoke()
  $Ps.PowerShell = $PowerShell
  
  [void]$Runspaces.Add($Ps)
}

foreach ($runspace in $Runspaces) {
  $Output = $runspace.PowerShell.EndInvoke($runspace.Handle)
  $runspace.PowerShell.Dispose()
}
#endregion

#region Actually Safe Results
$SafeArrayList
$SafeHashTable
$SafeInt
#endregion