#Simulates keyboard presses. Can execute any hotkeys as well as type text. 
#For a list of spcial keys see https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.sendkeys?view=windowsdesktop-8.0&redirectedfrom=MSDN
function Send-Wait {
    param($keys)
    [System.Windows.Forms.SendKeys]::SendWait($keys)
}