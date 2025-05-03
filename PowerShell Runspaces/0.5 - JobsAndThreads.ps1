$job = Start-Job -ScriptBlock {$env:computername} 
$job.ChildJobs.runspace.GetType()

$threadJob = Start-ThreadJob -ScriptBlock {[runspace]::DefaultRunspace.gettype()}
$threadjob.output
Get-Job
