# generate-ssl.ps1 - Generate self-signed wildcard SSL certificate for development

$CertDir = "certs"
$CertFile = "$CertDir\server.crt"
$KeyFile = "$CertDir\server.key"

if (-not (Test-Path $CertDir)) {
    New-Item -ItemType Directory -Force -Path $CertDir | Out-Null
}

Write-Host "🔐 Generating self-signed SSL certificate..."

# Check if OpenSSL is available (preferred)
if (Get-Command openssl -ErrorAction SilentlyContinue) {
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
        -keyout $KeyFile `
        -out $CertFile `
        -subj "/C=TR/ST=Istanbul/L=Istanbul/O=Development/OU=Development/CN=*.test" `
        -addext "subjectAltName=DNS:*.test,DNS:localhost"
} else {
    Write-Warning "OpenSSL not found. Using PowerShell to generate certificate."
    Write-Warning "Note: This will generate a PFX file, which we'll try to export to CRT/KEY."
    
    # Generate Cert
    $Cert = New-SelfSignedCertificate -DnsName "*.test", "localhost" -CertStoreLocation "Cert:\CurrentUser\My" -NotAfter (Get-Date).AddYears(1)
    
    # Export is tricky without OpenSSL to get pure .key file easily in Windows without admin rights or extra tools.
    # So we strongly recommend OpenSSL.
    Write-Error "For Nginx to work properly, we need separate .crt and .key files."
    Write-Error "Please install Git for Windows (which includes OpenSSL) or install OpenSSL manually."
    exit 1
}

Write-Host "✅ Certificate generated in ./certs/"
Write-Host "   - $CertFile"
Write-Host "   - $KeyFile"
Write-Host "ℹ️  This certificate is valid for '*.test' and 'localhost'."
