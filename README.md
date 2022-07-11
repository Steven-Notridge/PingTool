# PingTool

The main objective of this script is to record data to give to an ISP and record the timings, if it spikes during the day. Running a ping test consistently is pretty long and annoying. We test the connection to the outside world. If the connection is down, it records the time and date, also proving the connection to the router was alive. If it's not, it records that too. In my case, it kept restarting randomly too. If the connection is alive, but the ping is high, it will record that information as well as where it is going to. I've also now added *Schedule-OwnTool.ps1*, as a template for yourself if you want to use this format with a job of your own. 

# Running as a background script.

Download both scripts and place them into a folder. You'll need to amend the actual path's within the scripts to reflect this. Open a PowerShell window, and navigate to that path. Run Schedule-PingTool and it'll create the ScheduledJob for you, check it if it's not available, or start it if it was previously stopped. 
This has now been updated as of 11/07 - my initial error checking was not good enough and I've added more to it. I've also added a way to fix the scheduled job if it has any errors. 

If you want to stop the ScheduledJob from running, do the following;

- Open PowerShell
- Run `'Disable-ScheduledJob -Name PingTool'`
- Run `'Unregister-ScheduledJob -Name PingTool'`
- Check if it still exists by using `'Get-ScheduledJob'`

You can also just Disable it and leave it alive by using the first command.

# What I learnt from this

I tried really hard to get the Notification system to work. Ideally this would have ran in the background whilst I did other things, and got notified rather than watching a window for it. It doesn't seem to work that way however as it's on the front-end and the script is running in the back-end. There may be other ways to have this work, but I only wanted that specific notification as it was more of a modern approach. In a workplace, you could send an email depending on the results and add the information, which I may set up in the long run, but I don't have an Exchange setup currently to test this with. You could essentially just rip out the last ten lines of the log.txt file and attach it to an email for a quick solution.

The differences between Start-Job, ScheduledJobs, Looping and Error Handling. What I mean by Looping, is running the script as a Job based on a timer, or using `'while ($True)'` but as mentioned, it broke the Notification idea. Error Handling however, I managed to pass through custom exceptions and then had the notification run outside of the script. By using something like;

`If ($Error[0].FullyQualifiedErrorID -eq "InternetDown"){
  Write-Notification -Message 'Internet is down!' -LogPath /directory/blabla/`
  
I ended up creating a Module version for the Notification idea, as that'd allow me to use it in any script. I've uploaded it into this Repo just incase anyone else had a use for it. So I also learnt about Module creations and how to use custom Modules. 
  
I also found ways to create completely custom exceptions, by making new classes, but I didn't feel like I needed to try that here. But it's saved for the future. 
