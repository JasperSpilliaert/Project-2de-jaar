$domain = "ad.g03-fft.internal"
$policyName = "DenyCommandPromptAccess"
$linkOU = "OU=DomainUsers,DC=ad,DC=g03-fft,DC=internal"

# Verify if the GPO already exists in the domain
if (Get-GPO -Server $domain -Name $policyName -ErrorAction SilentlyContinue)  { 
    Write-Host "The GPO '$policyName' already exists"
} else {
    # If not, create a new GPO to restrict Command Prompt access
    New-GPO -Domain $domain -Name $policyName -Comment "Blocks access to the Command Prompt for compliance."
    Write-Host "New GPO '$policyName' has been created"

    # Implement the policy to disable Command Prompt (DisableCMD), Value 2 -> Both Command Prompt and batch processing are disabled, 1 -> only cmd disabled, 0 -> everything allowed
    Set-GPPrefRegistryValue -Name $policyName -Context User -Action Update -Key "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWORD -Value 2
    Write-Host "Command Prompt usage has been disabled for all Domain Users"
}

# Link the new or existing GPO to the relevant Organizational Unit
Get-GPO -Name $policyName | New-GPLink -Target $linkOU -LinkEnabled Yes
Write-Host "GPO '$policyName' is now linked to the '$linkOU'."

# Enforce a group policy update to apply the settings immediately
Invoke-GPUpdate -Force
Write-Host "Group Policy has been updated across the network."


