Import-Module ActiveDirectory

# OU structuur
New-ADOrganizationalUnit -Name "DomainUsers" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "NetworkManagement" -ProtectedFromAccidentalDeletion $false -Path "OU=DomainUsers, DC=ad, DC=g03-fft, DC=internal"
New-ADOrganizationalUnit -Name "WorkstationsEmployees" -ProtectedFromAccidentalDeletion $false -Path "OU=DomainUsers, DC=ad, DC=g03-fft, DC=internal"
New-ADOrganizationalUnit -Name "WinClient" -ProtectedFromAccidentalDeletion $false -Path "OU=NetworkManagement, OU=DomainUsers, DC=ad, DC=g03-fft, DC=internal"

New-ADOrganizationalUnit -Name "DomainWorkstations" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "PCs" -ProtectedFromAccidentalDeletion $false -Path "OU=Domainworkstations, DC=ad, DC=g03-fft, DC=internal"
New-ADOrganizationalUnit -Name "NetworkManagement" -ProtectedFromAccidentalDeletion $false -Path "OU=PCs, OU=Domainworkstations, DC=ad, DC=g03-fft, DC=internal"
New-ADOrganizationalUnit -Name "WorkstationsEmployees" -ProtectedFromAccidentalDeletion $false -Path "OU=PCs, OU=Domainworkstations, DC=ad, DC=g03-fft, DC=internal"
New-ADOrganizationalUnit -Name "WinClient" -ProtectedFromAccidentalDeletion $false -Path "OU=NetworkManagement, OU=PCs, OU=DomainWorkstations, DC=ad, DC=g03-fft, DC=internal"

$ADUsers = Import-Csv "C:\Users\Administrator\Downloads\gebruikers.csv" -Delimiter ";"
$domain = "ad.g03-fft.internal"

# gebruikers & computers aanmaken per OU

foreach ($User in $ADUsers) {
    $voornaam = $User.Voornaam
    $achternaam = $User.Achternaam
    $initialen = $User.Initialen
    $gebruikersnaam = $User.Gebruikersnaam
    $email = $User.Email
    $password = $user.Password
    $OU = $User.OU

    if ($OU.Contains("OU=DomainUsers")) {
        if (Get-ADUser -F { SamAccountName -eq $gebruikersnaam }) {
            Write-Warning "Gebruiker met volgende gebruikersnaam bestaat reeds: $gebruikersnaam"
        }
        Else {
            New-ADUser `
                -SamAccountName $gebruikersnaam `
                -UserPrincipalName "$gebruikersnaam@$domain" `
                -Name "$voornaam $achternaam" `
                -GivenName $voornaam `
                -Surname $achternaam `
                -Displayname "$voornaam $achternaam" `
                -Initials $initialen `
                -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -ChangePasswordAtLogon $True `
                -EmailAddress $email `
                -Department $departement `
                -Path $OU `
                -Enabled $true

            Write-Host "Gebruiker met volgende gebruikersnaam werd aangemaakt: $gebruikersnaam"
        }
    } 
    ElseIf ($OU.Contains("OU=DomainWorkstations")) {
        # WERKT !!!!!!
        $compSamAccountName = "$gebruikersnaam$"

        if (Get-ADComputer -F { SamAccountName -eq $compSamAccountName }) {
            Write-Warning "Computer met volgende naam bestaat reeds: $gebruikersnaam"
        }
        Else {
            New-ADComputer `
                -SamAccountName $compSamAccountName `
                -Name $gebruikersnaam `
                -DisplayName $gebruikersnaam `
                -Path $OU `
                -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -ChangePasswordAtLogon $True `
                -Enabled $true

            Write-Host "Computer met volgende naam werd aangemaakt: $gebruikersnaam"
        }

    }

}


