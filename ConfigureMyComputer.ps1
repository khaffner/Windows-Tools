#Determining if script is running with administrative privileges
$IsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

$LARUserName = 'A'
$STDUserNAme = 'Kevin'

if($IsAdmin) {
    if($env:USERNAME -eq $STDUserNAme) {
        #My user is admin :(
        #Install some things that need administrative privileges.

        #Creating the LAR user if it does not exist.
        $LARUser = Get-LocalUser -Name $LARUserName
        if(!($LARUser)) {
            #LARUser does not exist
            $LARUserPassword = Read-Host -Prompt 'Enter the password for the LAR User "A"' -AsSecureString
            New-LocalUser -Name $LARUserName -FullName 'LAR User' -PasswordNeverExpires -Password $LARUserPassword
        }
        else {
            if((Get-LocalGroupMember -Name 'Administrators').Name -notcontains "$env:COMPUTERNAME\$($LARUser.Name)") {
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