$ScriptBlock = 
{
    param($attempt)

    #random Error
    if ($attempt -eq 5)
    {
        #for($i = 0; $i -lt 1000;$i++) {start-sleep -seconds 1} #random hang
        #[System.Environment]::FailFast("Simulated crash") #random crash
        Throw "5!!!! really? How dare you!?" # random error
    }

    #Runspaces store variables
    $variable = $attempt

    #just add time for demo
    Start-sleep -second 5
}

$MINRunspaces = 1
$MAXRunspaces = 10
$initialSessionState = [initialsessionstate]::CreateDefault() 
$RunSpacePool = [RunspaceFactory]::CreateRunspacePool($minRunspaces,$MAXRunspaces,$initialSessionState,$Host)
$RunSpacePool.Open()
$PowershellArray = @()
For ($Counter = 0; $Counter -lt 10; $counter++){
    $PowerShell = [PowerShell]::Create()
    $PowerShell.Runspacepool = $RunSpacePool
    $Null = $PowerShell.AddScript($ScriptBlock)
    $Null = $PowerShell.AddParameter('attempt',$Counter)
    $Null = $PowerShell.BeginInvoke()
    $PowershellArray += $powershell
}
Start-sleep -Seconds 1

#Find Error and runspace
$BadPowershell = $PowershellArray.where({$PSItem.haderrors})
$BadPowershell[-1].InvocationStateInfo
$r = get-runspace
$BadRunspace = $r.where({$PSITem.SessionStateProxy.PSVariable.Get("error").value.Count -gt 0})
$BadRunspace[-1].SessionStateProxy.PSVariable.Get("error")

#enter Hung runspace (Maybe?)
# debug-runspace doesnt work with a runspacepool
$r = (get-runspace).where({$PSItem.RunspaceAvailability -eq 'Busy'})
$r[-1].Debugger.GetCallStack()|select *
