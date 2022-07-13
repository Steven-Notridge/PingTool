# Schedule Job for PingTool, and start displaying as log file. I don't want to have to type any commands to start and monitor everything.
# Updating checking methods. Restarted PC and checked in the morning, it said it was all enabled and running fine, so it started monitoring as normal.
# I later checked it by disabling the Network Adapter and no errors were reported, I then found no jobs being ran for the script and the ScheduledJob seems busted.
<#
Adding checks for;
- Log file (L01) - Done.
- Scheduled Job Exist (SJ01) - Done
- Scheduled Job Enabled (SJ02) - Done
- Leftover Jobs (J01) - Done
- Unregister failure (UF01) - Done
#>
# All needs checking over again on a clear mind.

# Start - (J01)
function Remove-OldJobs {
    param (
        [Parameter(Mandatory = $true)] [string] $JobName,
        [Parameter(Mandatory = $false)] [string] $Ago
    )
    Get-Job -Name "$JobName" -After "$Ago" | Remove-Job
}
# End - (J01)

$JobAlive = Get-ScheduledJob -Name "PingTool" -ErrorAction SilentlyContinue
$FilePath = "C:\Sysadmin\GitCommits\PingTool\PingTool.ps1"
$Date = Get-Date -Format dd/MM/yyyy
$TaskTrigger = (New-JobTrigger -Once -At "$Date" -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::MaxValue))

# Start - (L01)

$LogExist = Get-Item -Path "C:\Sysadmin\GitCommits\PingTool\Log.txt" -ErrorAction SilentlyContinue

Write-Host "Checking log file existence." -ForegroundColor Yellow
Write-Host "`r"

If ([bool]($LogExist) -eq $False){
    Write-Host "No Log file detected. Creating new file..." -ForegroundColor Yellow
    Write-Host "`r"
    New-Item -Path . -Name "Log.txt" -ItemType "file" | Out-Null
    Start-Sleep -Seconds 1
    $LogExist = Get-Item -Path "C:\Sysadmin\GitCommits\PingTool\Log.txt" -ErrorAction SilentlyContinue
    If ([bool]($LogExist) -eq $True){
        Write-Host "Log file created." -ForegroundColor Green
    }
    Else {
        Write-Host "Log file creation failed. Exiting script. Please ensure file is created within the same location as this script." -ForegroundColor Red
        Exit
    }
}
else {
    Write-Host "Log file detected." -ForegroundColor Green
}

# End - (L01)

# Start - (SJ01)

# Does the Scheduled Job exist?
# No the job does not exist.
If ([bool]($JobAlive) -eq $False){
    Write-Host "`r"
    Write-Host "No Job found. Creation will follow." -ForegroundColor Yellow
    Register-ScheduledJob -Name 'PingTool' -FilePath $FilePath -Trigger $TaskTrigger | Out-Null
    # Now that the Scheduled Job has been created...
    If ([bool](Get-ScheduledJob -Name "PingTool") -eq $True){
        $Job = Get-ScheduledJob -Name "PingTool"
        Write-Host "`r"
        Start-Sleep -Seconds 1
        Write-Host "Job created, with ID of" $Job.Id -ForegroundColor Green
        Write-Host "`r"
        # Check to see if Job is running as expected.
        If ($Job.Enabled -eq $True){
            Write-Host "Status is now"$Job.Enabled -ForegroundColor Green
            # Should add a bit here to ensure Job properly starts. Like if Get-Job -Name "PingTool" -After X exists, confirm with a message and if not, write error.
        }
        # Creation of the Scheduled Job was attempted but did not succeed.
        Else {
            Write-Host "Status is now"$Job.Enabled -ForegroundColor Red
            Write-Host "See below for Error."
            Write-Output $Error[0]
            Exit
        }
        # Referenced (J01)
        Write-Host "Removing old jobs that may be left over." -ForegroundColor Yellow
        Remove-OldJobs -Name "PingTool" 
        Start-Sleep -Seconds 1
        Write-Host "Force starting Job for first run." -ForegroundColor Yellow
        (Get-ScheduledJob -Name "PingTool").StartJob() | Out-Null
        Start-Sleep -Seconds 1
        Write-Host "`r"
    }

    Else {
            Write-Output $Error[0]
            Exit
    }
}


# Yes, the Scheduled Job Exists.
elseif ([bool]($JobAlive) -eq $True) {
    Write-Host "`r"
    Write-Host "Job Detected, checking current state." -ForegroundColor Green
    $Job = Get-ScheduledJob -Name "PingTool"
    # Start - (SJ02)
    # If Scheduled Job Exists but is not enabled.
    if ($Job.Enabled -eq $false){
        Write-Host "Job is not enabled. Starting Job." -ForegroundColor Yellow
        Enable-ScheduledJob -Name "PingTool" | Out-Null
        Start-Sleep -Seconds 2
        # If Enabling the Scheduled Job failed.
        if ($Job.Enabled -eq $false){
            Write-Host "Status is"$Job.Enabled -ForegroundColor Red
            Write-Host "Job will be recreated as it's not working correctly." -ForegroundColor Yellow
            Get-Job "PingTool" | Remove-Job
            Start-Sleep -Seconds 1
            Write-Host "Removed old Jobs that may have been stuck. Removing Scheduled Task for recreation." -ForegroundColor Yellow
            # Try to remove the scheduled job.
            Unregister-ScheduledJob "PingTool"
            Start-Sleep -Seconds 1
            # Start - (UF01)
            # If removing it fails...
            If (Unregister-ScheduledJob "PingTool".CategoryInfo -eq [System.InvalidOperationException]){
                Write-Host "Terminating Script. You should try removing the ScheduledJob with Admin rights." -ForegroundColor Yellow
                Exit
            }
            # End - (UF01)
            # If removing it succeeds, recreate the scheduled Job.
            Else {
                Write-Host "Job has been removed. Now recreating the Scheduled Job." -ForegroundColor Green
                Register-ScheduledJob -Name 'PingTool' -FilePath $FilePath -Trigger $TaskTrigger | Out-Null
                Write-Host "`r"
                Start-Sleep -Seconds 1
                Write-Host "Job created, with ID of" $Job.Id -ForegroundColor Green
                Write-Host "`r"
                Write-Host "Force starting Job for first run." -ForegroundColor Yellow
                (Get-ScheduledJob -Name "PingTool").StartJob() | Out-Null
                # Needs check to see if normal Job is created and report.
            }
            Start-Sleep -Seconds 1
        }
        # If SchJob is Enabled.
        else {
            Write-Host "Status is"$Job.Enabled -ForegroundColor Green
        }
        
    }
    # If Scheduled Job exists, and is already enabled.
    else {
        Write-Host "`r"
        Write-Host "Job is already enabled." -ForegroundColor Green
    }
    # End - (SJ02)
}

# This needs a section to ensure the last job wasn't ages ago, and clear queue if it was.
else {
    Write-Host "Nothing required. Script continuing."
    $TimeAgo = $Date.AddDays(-1)
    Write-Host "Removing Legacy Jobs." -ForegroundColor Yellow
    Remove-OldJobs -Name "PingTool" -Ago $TimeAgo
}
Write-Host "`r"
Write-Host "Monitoring Log file..."
Write-Host "`r"
Get-Content -Path "C:\Sysadmin\GitCommits\PingTool\Log.txt" -Tail 4 -Wait