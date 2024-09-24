# Path to the certificate file
$certificatePath = "C:\path\to\your\certificate.cer"

# Import the certificate
$certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$certificate.Import($certificatePath)

# Open the Certificates snap-in for the Local Computer
$certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
$certStore.Open("ReadWrite")

# Add the certificate to the store
$certStore.Add($certificate)

# Close the certificate store
$certStore.Close()

Write-Host "Certificate added to Trusted Root Certification Authorities store."
