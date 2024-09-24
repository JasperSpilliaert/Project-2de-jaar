$DomainName = "ad.g03-fft.internal" # "G03fft"
$DomainAdmin = "Administrator"
$Password = ConvertTo-SecureString -AsPlainText "23Admin24" -Force
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainAdmin, $Password)

Add-Computer -DomainName $DomainName -Credential $Credential -Restart -Force