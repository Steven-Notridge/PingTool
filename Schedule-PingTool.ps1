# Schedule Job for PingTool, and start displaying as log file. I don't want to have to type any commands to start and monitor everything.

$JobAlive = Get-ScheduledJob -Name "PingTool" -ErrorAction SilentlyContinue
$FilePath = "C:\Sysadmin\GitCommits\PingTool\PingTool.ps1"
$TaskTrigger = (New-JobTrigger -Once -At "07/03/2022 0am" -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::MaxValue))

If ([bool]($JobAlive) -eq $False){
    Write-Host "`r"
    Write-Host "No Job found. Creation will follow." -ForegroundColor Yellow
    Register-ScheduledJob -Name 'PingTool' -FilePath $FilePath -Trigger $TaskTrigger | Out-Null
    If ([bool](Get-ScheduledJob -Name "PingTool") -eq $True){
        $Job = Get-ScheduledJob -Name "PingTool"
        Write-Host "`r"
        Start-Sleep -Seconds 1
        Write-Host "Job created, with ID of" $Job.Id -ForegroundColor Green
        Write-Host "`r"
        Write-Host "Force starting Job for first run." -ForegroundColor Yellow
        (Get-ScheduledJob -Name "PingTool").StartJob() | Out-Null
        Start-Sleep -Seconds 1
        Write-Host "`r"
        If ($Job.Enabled -eq $True){
            Write-Host "Status is now"$Job.Enabled -ForegroundColor Green
        }
        Else {
            Write-Host "Status is now"$Job.Enabled -ForegroundColor Red
            Write-Host "See below for Error."
            Write-Output $Error[0]
            Break
        }
    }
}

elseif ([bool]($JobAlive) -eq $True) {
    Write-Host "`r"
    Write-Host "Job Detected, checking current state." -ForegroundColor Green
    $Job = Get-ScheduledJob -Name "PingTool"
    if ($Job.Enabled -eq $false){
        Write-Host "Job is not enabled. Starting Job." -ForegroundColor Yellow
        Enable-ScheduledJob -Name "PingTool" | Out-Null
        Start-Sleep -Seconds 1
        Write-Host "Status is"$Job.Enabled -ForegroundColor Green
    }
    else {
        Write-Host "`r"
        Write-Host "Job is already enabled." -ForegroundColor Green
    }
}

else {
    Write-Host "Nothing required. Script continuing."
}
Write-Host "`r"
Write-Host "Monitoring Log file..."
Write-Host "`r"
Get-Content -Path "C:\Sysadmin\GitCommits\PingTool\Log.txt" -Tail 4 -Wait