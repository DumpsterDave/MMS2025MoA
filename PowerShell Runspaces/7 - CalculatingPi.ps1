$ScriptBlock = 
{
param($times)
    For($i = 0; $i -lt $times;$i++){
        [double] $halfpi=1
        [int] $num=1
        [double] $factorial=1
        [double] $oddfactorial=1
        [double] $pi = 1
        [double] $previouspi = 0

        while ($previouspi -ne $pi) {
            $previouspi = $pi
            $factorial *= $num
            $oddfactorial *= (($num*2)+1)
            $halfpi += $factorial / $oddfactorial
            $pi = 2 * $halfpi
            $num++
        }
    }
}

#region Test full runspace vs constrained
$times = 1000
$empty = Measure-Command {
    $initialSessionStateEmpty = [initialsessionstate]::Create()
    $initialSessionStateEmpty.LanguageMode = "Full"
    $RunSpaceEmpty = [RunspaceFactory]::CreateRunspace($initialSessionStateEmpty)
    $RunSpaceEmpty.open()
    $powershell = [powershell]::Create()
    $PowerShell.Runspace = $RunSpaceEmpty
    $Null = $PowerShell.AddScript($ScriptBlock)
    $Null = $PowerShell.AddParameter('Times',$times)
    $Null = $PowerShell.Invoke()
    $RunSpaceEmpty.close()
    $RunSpaceEmpty.Dispose()
}

$default = Measure-Command {
    $initialSessionStateDefault = [initialsessionstate]::CreateDefault() 
    $RunSpaceDefault = [RunspaceFactory]::CreateRunspace($initialSessionStateDefault)
    $RunSpaceDefault.open()
    $powershell = [powershell]::Create()
    $PowerShell.Runspace = $RunSpaceDefault
    $Null = $PowerShell.AddScript($ScriptBlock)
    $Null = $PowerShell.AddParameter('Times',$times)
    $Null = $PowerShell.Invoke()
    $RunSpaceDefault.close()
    $RunSpaceDefault.Dispose()
}

Write-Output "Empty - $($empty.TotalSeconds)"
Write-Output "default - $($default.TotalSeconds)"
#end region



# Does more threads help?
foreach ($Threads in (5..15)){
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $initialSessionState = [initialsessionstate]::CreateDefault() # Enter PSSnapins here
    $MINRunspaces = 1
    $MAXRunspaces = $Threads
    $RunSpacePool = [RunspaceFactory]::CreateRunspacePool($minRunspaces,$MAXRunspaces,$initialSessionState,$Host)
    $RunSpacePool.Open()
    $times = 10000/$Threads
    $PowershellArray = @()
    For ($Counter = 0; $Counter -lt 10; $counter++){
        $PowerShell = [PowerShell]::Create()
        $PowerShell.Runspacepool = $RunSpacePool
        $Null = $PowerShell.AddScript($ScriptBlock)
        $Null = $PowerShell.AddParameter('Times',$times)
        $Null = $PowerShell.BeginInvoke()
        $PowershellArray += $powershell
    }
    Start-sleep -Seconds 1
    While ($PowershellArray.InvocationStateInfo.State -contains 'Running'){
    }
    $stopwatch.Stop()
    "$Threads - $($Stopwatch.Elapsed)"
}