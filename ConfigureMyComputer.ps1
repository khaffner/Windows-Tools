#Determining if script is running with administrative privileges
$IsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

$LARUserName = 'A'
$STDUserNAme = 'Kevin'

$ErrorActionPreference = 'Stop'

if ($IsAdmin) {
    if ($env:USERNAME -eq $STDUserNAme) {
        #My user is admin :(
        #Install some things that need administrative privileges.

        $VlCInstaller = "$env:TEMP\VLC.exe"
        Invoke-WebRequest -Uri 'https://ftp.acc.umu.se/mirror/videolan.org/vlc/3.0.1/win64/vlc-3.0.1-win64.exe' -OutFile $VlCInstaller
        Start-Process -FilePath $VlCInstaller -ArgumentList '/S'

        $ChromeInstaller = "$env:TEMP\Chrome.msi"
        Invoke-WebRequest -Uri 'https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi' -OutFile $ChromeInstaller
        Start-Process -FilePath msiexec -ArgumentList "/i $ChromeInstaller /qn" -Wait

        $VScodeInstaller = "$env:TEMP\vscode.exe"
        Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?Linkid=852157" -OutFile $VScodeInstaller
        Start-Process -FilePath $VScodeInstaller -ArgumentList "/verysilent /suppressmsgboxes"

        $GithubDesktopInstaller = "$env:TEMP\GithubDesktop.exe"
        Invoke-WebRequest -Uri "https://central.github.com/deployments/desktop/desktop/latest/win32" -OutFile $VScodeInstaller
        Start-Process -FilePath $GithubDesktopInstaller

        #Creating the LAR user if it does not exist.
        $LARUser = Get-LocalUser -Name $LARUserName
        if (!($LARUser)) {
            #LARUser does not exist
            $LARUserPassword = Read-Host -Prompt 'Enter the password for the LAR User "A"' -AsSecureString
            New-LocalUser -Name $LARUserName -FullName 'LAR User' -PasswordNeverExpires -Password $LARUserPassword
        }
        else {
            if ((Get-LocalGroupMember -Name 'Administrators').Name -notcontains "$env:COMPUTERNAME\$($LARUser.Name)") {
                #A is not admin
                Add-LocalGroupMember -Group 'Administrators' -Member (Get-LocalUser -Name $LARUserName)
            }
        }
        #Removing my administrative privileges
        Remove-LocalGroupMember -Group 'Administrators' -Member (Get-LocalUser -Name $STDUserNAme)
    }
    else {
        Write-Error "What the hell, $env:USERNAME"
        pause
    }
}
else {
    #User setup. Download, install and do stuff that does not require admin.
    
}