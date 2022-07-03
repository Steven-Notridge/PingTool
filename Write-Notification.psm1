function Write-Notification {

    # Create a parameter that allows us to type a message that we want to use later on.
    param (
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $LogPath
    )
    # Setting up the notification
    [reflection.assembly]::loadwithpartialname('System.Windows.Forms')
    [reflection.assembly]::loadwithpartialname('System.Drawing')
    $notify = New-Object system.windows.forms.notifyicon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $notify.ShowBalloonTip(5000,'WARNING',$Message,[system.windows.forms.tooltipicon]::None)
    # Unregister-Event clears the previous job, this is to stop overlapping if ran several times. It's necessary otherwise the next line won't execute correctly.
    Unregister-Event -SourceIdentifier BalloonClicked_event -ErrorAction SilentlyContinue
    # Executing code if the Notification is clicked.
    # Set-Location used instead of a -WorkingDirectory flag because it just refused to open.
    Set-Location -Path $LogPath
    Register-ObjectEvent $notify BalloonTipClicked BalloonClicked_event -Action {Start-Process .\Log.txt} | Out-Null
}