# Gebruiker kiezen
$userChoice = Read-Host "Kies de gebruiker voor de VM setup (Kies '1' voor Jasper, '2' voor Leonard, '3' voor Simon, '4' voor Jorik, '5' voor Wout, '6' to specify custom paths)"
switch ($userChoice) {
    "1" {
        $userName = "Jasper"
        $iso_path = "C:\Users\peter\Downloads\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"
        $vdi_path = "C:\Users\peter\VirtualBox VMs\$vm_name\$vm_name.vdi"
        $bridged_adapter_name = "Realtek RTL8822CE 802.11ac PCIe Adapter"
    }
    "2" {
        $userName = "Leonard"
        $iso_path = "D:\school\school\Jaar 4\SEP\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"
        $vdi_path = "D:\school\school\Jaar 4\SEP\$vm_name\$vm_name.vdi"
        $bridged_adapter_name = "Realtek PCIe GbE Family Controller"
    }
    "3" {
        $userName = "Simon"
        $iso_path = "C:\Users\simon\Documents\Virtual Machines\ISOs\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"
        $vdi_path = "C:\Users\simon\Documents\Virtual Machines\$vm_name\$vm_name.vdi"
        $bridged_adapter_name = "Realtek PCIe GbE Family Controller"
    }
    "4" {
        $userName = "Jorik"
        $iso_path = "C:\HoGent\2deJaar\sep\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"
        $vdi_path = "C:\Users\braet\VirtualBox VMs$vm_name\$vm_name.vdi"
        $bridged_adapter_name = "Realtek PCIe GbE Family Controller"
    }
    "5" {
        $userName = "Wout"
        $iso_path = "C:\HoGent3\SEP\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"
        $vdi_path = "C:\Users\woutv\VirtualBox VMs\$vm_name\$vm_name.vdi"
        $bridged_adapter_name = "Realtek Gaming GbE Family Controller"
    }
    "6" {
        $userName = "Custom User"
        $iso_path = Read-Host "Enter the full path to the ISO file"
        $vdi_path = Read-Host "Enter the full path for the virtual hard disk"
        $bridged_adapter_name = Read-Host "Enter the name of the Bridged Adapter"
    }
    default {
        Write-Host "Ongeldige selectie, exiting..."
        exit
    }
}

# Overige variabelen
$vm_name = "WindowsClient"
$os_type = "Windows10_64"
$domain_name = "ad.g03-fft.internal"
$user_name = "Administrator"
$password = "23Admin24"
$ram = 4096
$vram = 128
$processor_cores = 2
$drive_size = 25000
$network_adapter1 = "bridged"
$graphics_controller = "vboxsvga"

# Windows 10 VM aanmaken
vboxmanage createvm --name $vm_name --ostype $os_type --register

# VM specificaties instellen
vboxmanage modifyvm $vm_name --memory $ram --vram $vram --cpus $processor_cores --graphicscontroller $graphics_controller
vboxmanage modifyvm $vm_name --nic1 $network_adapter1 --bridgeadapter1 $bridged_adapter_name

# Virtuele schijf aanmaken
vboxmanage createmedium disk --filename $vdi_path --size $drive_size

# Storage controllers en mediums configureren
vboxmanage storagectl $vm_name --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach $vm_name --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vdi_path
vboxmanage storageattach $vm_name --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $iso_path

# Boot volgorde instellen
vboxmanage modifyvm $vm_name --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Automatische installatie configureren
vboxmanage unattended install $vm_name `
    --iso $iso_path `
    --hostname "$vm_name.$domain_name" `
    --user $user_name `
    --password $password `
    --country BE `
    --locale nl_BE `
    --install-additions `
    --post-install-command "powershell Set-ExecutionPolicy RemoteSigned -Scope LocalMachine ; Shutdown /r /t 5"

# VM starten
vboxmanage startvm $vm_name
