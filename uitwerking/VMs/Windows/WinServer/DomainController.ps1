# Variables
$vmnaam = "DomainController"
$ostype = "Windows2022_64"
$geheugen = 2048
$vram = 128
$processorkernen = 1
$netwerkadapter1 = "bridged" # bridged
$bridged_adapter_name = "Realtek RTL8822CE 802.11ac PCIe Adapter"
$drivesize1 = 20000


#------------------------------------------------------------------------------------------------------------------------------------------------------

# Aanmaken Windows Server 2022
vboxmanage createvm --name "$vmnaam" --ostype $ostype --register

vboxmanage modifyvm $vmnaam --memory $geheugen --vram $vram
vboxmanage modifyvm $vmnaam --cpus $processorkernen
vboxmanage modifyvm $vmnaam --nic1 $netwerkadapter1 --bridgeadapter1 $bridged_adapter_name

# Toevoegen VDI & ISO, opstartvolgorde Boot drives
vboxmanage createmedium --filename "C:\Users\peter\VirtualBox VMs\$vmnaam\DomeinController22.vdi" --size $drivesize1

vboxmanage storagectl $vmnaam --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach $vmnaam --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "C:\Users\peter\VirtualBox VMs\$vmnaam\DomeinController22.vdi"
vboxmanage storageattach $vmnaam --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "C:\Users\peter\OneDrive\Bureaublad\HOGENT\2de\semester2\SEP\WinServer\ISO\en-us_windows_server_2022_x64_dvd_620d7eac(3).iso"

vboxmanage modifyvm $vmnaam --boot1 dvd --boot2 disk --boot3 none --boot4 none

#------------------------------------------------------------------------------------------------------------------------------------------------------

# Automatische installatie
vboxmanage unattended install $vmnaam `
    --iso "C:\Users\peter\OneDrive\Bureaublad\HOGENT\2de\semester2\SEP\WinServer\ISO\en-us_windows_server_2022_x64_dvd_620d7eac(3).iso" `
    --hostname "ad.g03-fft.internal" `
    --user "Administrator" `
    --password "23Admin24" `
    --country "BE" `
    --locale "nl_BE" `
    --additions-iso "C:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso" `
    --install-additions `
    --post-install-command "Shutdown /r /t 5"

#------------------------------------------------------------------------------------------------------------------------------------------------------

vboxmanage modifyvm $vmnaam --clipboard bidirectional
vboxmanage modifyvm $vmnaam --draganddrop bidirectional
    
vboxmanage startvm $vmnaam
