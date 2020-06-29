$a = Get-WindowsCapability -Online -Name Open*
if($a){

    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Get-Service sshd
    Get-Service ssh-agent
    Set-Service -Name sshd -StartupType Automatic
    Set-Service -Name ssh-agent -StartupType Automatic
    Start-Service sshd
    Start-Service ssh-agent
}