#Based on http://techibee.com/powershell/get-active-window-on-desktop-using-powershell/2178
Function Get-ActiveWindow {
[CmdletBinding()]
Param(
)
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class UserWindows {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@
    while ($true) {
        $TimeStamp = (Get-Date -Format HH:mm:ss)
        if(!(Get-Process -Name logonui -ErrorAction SilentlyContinue)) {
                $ActiveHandle = [UserWindows]::GetForegroundWindow()
                $Process = (Get-Process | where MainWindowHandle -eq $activeHandle).ProcessName
                if(!($Process)) {
                    $Process = "explorer"
                }
        }
        else {
            $Process = "Locked"
        }
        Out-File -FilePath $env:TEMP\ActiveWindow.csv -InputObject "$TimeStamp;$Process" -Append -Force
        Start-Sleep -Seconds 1
    }
}