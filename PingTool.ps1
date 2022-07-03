# Created by @Steven-Notridge - https://github.com/Steven-Notridge/
# The main objective of this script is to record data to give to an ISP and record the timings, if it spikes during the day. Running a ping test consistently is pretty long and annoying.
# We test the connection to the outside world.
# If the connection is down, it records the time and date, also proving the connection to the router was alive. If it's not, it records that too. In my case, it kept restarting randomly too.
# If the connection is alive, but the ping is high, it will record that information as well as where it is going to.
# We no longer run this with the Notifications. Though it's a cool idea, it's not practical and isn't really fitting for a 'workplace' - You would have some logging and monitoring instead.
# Then again, this was a personal project, instead of being a 'workplace' project, however we may as well investigate what else can happen.

# UK Date formatting.
$Date = Get-Date -format "dd/MM HH:mm"

# First Section
$Alive = "1.1.1.1"
# Retrieving True/False value of the ping test. Is the connection alive?
$TesterBoolean = Test-Connection $Alive -Quiet
# Same as above but to the router.
$TesterRouter = Test-Connection 192.168.0.1 -Quiet

# Second Section
# Not to be confused with the $TesterBoolean, this will reply with actual timings.
$ResponseTime = Test-Connection $Alive -Count 5
# We format the timings, and grab the Maximum ping, and the Average of all 5 pings.
$RT = $ResponseTime.ResponseTime | Measure-Object -Maximum -Average
# Cleaner formatting for use in the script.
$RTAverage = $RT.Average
$RTMax = $RT.Maximum

Set-Location -Path "C:\Sysadmin\GitCommits\PingTool\"

# If the connection fails...
if ($TesterBoolean -eq $False) {
    Write-Host 'No Connection! The time is:' $Date
    # Create a variable for the message to avoid issues with new lines.
    $msg = "[$Date] No Connection to $Alive!"
    Write-Output $msg | Out-File -FilePath .\Log.txt -Append
    # If the connection to the router fails...
    if ($TesterRouter -eq $False) {
        Write-Host 'Connection to the Router has also failed, did it restart again?'
        Write-Output "Connection to the Router has also failed, did it restart again?" | Out-File -FilePath .\Log.txt -Append
        Write-Output "`n" | Out-File -FilePath .\Log.txt -Append
    }
    # If the connection to the router is alive...
    else {
        $msg = "The connection to the Router was successful."
        Write-Output $msg | Out-File -FilePath .\Log.txt -Append
        Write-Output "`n" | Out-File -FilePath .\Log.txt -Append
    }
}

# If the connection to the outside world is alive...
else {
    Write-Host 'Connection is alive.'
    # But the repsonse time is too high...
    if ($ResponseTime.ResponseTime -gt '75'){
        Write-Host 'Ping is reaching high values however.'
        Write-Output "`n" | Out-File -FilePath .\Log.txt -Append
        # Retrieve the Average and Maximum response times.
        $msg = "[$Date] Ping is reaching high values. The average response time was $RTAverage ms to $Alive, whilst the maximum response time was $RTMax ms."
        Write-Output $msg | Out-File -FilePath .\Log.txt -Append
    }
}