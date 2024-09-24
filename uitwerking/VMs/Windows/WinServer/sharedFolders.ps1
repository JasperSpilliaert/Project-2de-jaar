# Setup base directory for user shares
$mainDirectory = "C:\Shares"
if (-not (Test-Path $mainDirectory)) {
    New-Item -Path $mainDirectory -ItemType Directory
}

# Retrieve user accounts from Active Directory
$domainUsers = Get-ADUser -Filter * -SearchBase "OU=DomainUsers,DC=ad,DC=g03-fft,DC=internal" | Select-Object -ExpandProperty SamAccountName
$domainAdmins = "Domain Admins"

# Process each user
foreach ($user in $domainUsers) {
    $userSharePath = Join-Path $mainDirectory $user
    if (-not (Test-Path $userSharePath)) {
        New-Item -Path $userSharePath -ItemType Directory
    }

    # Setup SMB share with specific permissions
    New-SmbShare -Name "$user" -Path $userSharePath -FullAccess $user, $domainAdmins -FolderEnumerationMode AccessBased

    # Configure NTFS permissions
    $acl = Get-Acl $userSharePath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$user", "FullControl", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $userSharePath -AclObject $acl
}



