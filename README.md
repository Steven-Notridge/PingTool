# PingTool

The main objective of this script is to record data to give to an ISP and record the timings, if it spikes during the day. Running a ping test consistently is pretty long and annoying. We test the connection to the outside world. If the connection is down, it records the time and date, also proving the connection to the router was alive. If it's not, it records that too. In my case, it kept restarting randomly too. If the connection is alive, but the ping is high, it will record that information as well as where it is going to.

# Running as a background script.

Currently used the Task Scheduler to run this, but I'm going to look into other ways to have it running. I'd also like to consider the option of it being ran within a PowerShell window on another screen for example.


TODO

- Consistent Ping option, that will then report and retain the past X amount of pings. (Faster and more reliable feedback.)
- Ponder existence
