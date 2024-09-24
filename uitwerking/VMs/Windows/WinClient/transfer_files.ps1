$VM_NAME = "WindowsClient"
$USER_NAME = "Administrator"
$PASSWORD = "23Admin24"

$userChoice = Read-Host "Kies de gebruiker voor de VM setup (Kies '1' voor Jasper, '2' voor Leonard)"
if ($userChoice -eq "1") {
    $userName = "Jasper"
    $test =  "C:\Users\peter\OneDrive\Bureaublad\HOGENT\2de\semester2\SEP"
} elseif ($userChoice -eq "2") {
    $userName = "Leonard"
    $test = "D:\school\school\Jaar 4\SEP"
} else {
    Write-Host "Invalid selection. Exiting script."
    exit
}

vboxmanage guestcontrol $VM_NAME copyto --target-directory "C:\Users\$USER_NAME\Desktop\config.ps1" "$test\sep2324-gent-g03\uitwerking\VMs\Windows\WinClient\config.ps1" --username $USER_NAME --password $PASSWORD

vboxmanage guestcontrol $VM_NAME copyto --target-directory "C:\Users\$USER_NAME\Desktop\joinAD.ps1" "$test\sep2324-gent-g03\uitwerking\VMs\Windows\WinClient\joinAD.ps1" --username $USER_NAME --password $PASSWORD

vboxmanage guestcontrol $VM_NAME copyto --target-directory "C:\Users\$USER_NAME\Desktop\networksharesTest.ps1" "$test\sep2324-gent-g03\uitwerking\VMs\Windows\WinClient\networksharesTest.ps1" --username $USER_NAME --password $PASSWORD

#vboxmanage guestcontrol $VM_NAME copyto --target-directory "D:\school\school\Jaar 4\SEP\sep2324-gent-g03\uitwerking\VMs\Windows\WinClient\key.crt" "$test\sep2324-gent-g03\uitwerking\VMs\Windows\WinClient\key.crt" --username $USER_NAME --password $PASSWORD