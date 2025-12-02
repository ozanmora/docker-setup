# cli.ps1 - Unified helper script for Docker Setup

param (
    [string]$Command,
    [string]$Arg1,
    [string]$Arg2
)

function Show-Help {
    Write-Host "Usage: ./cli.ps1 <command> [arguments]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  create-site <domain> <path>   Create a new Nginx config for a site"
    Write-Host "  add-path <path> <name>        Map an external project path to Docker"
    Write-Host "  ssl-generate                  Generate self-signed SSL certificates"
    Write-Host "  ssl-trust                     Trust the generated SSL certificate"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  ./cli.ps1 create-site laravel.test example/laravel/public"
    Write-Host "  ./cli.ps1 add-path ""C:\Projects\site"" site-name"
    Write-Host "  ./cli.ps1 ssl-generate"
    Write-Host "  ./cli.ps1 ssl-trust"
}

if ([string]::IsNullOrEmpty($Command)) {
    Show-Help
    exit
}

switch ($Command) {
    "create-site" {
        if ([string]::IsNullOrEmpty($Arg1) -or [string]::IsNullOrEmpty($Arg2)) {
            Write-Host "Usage: ./cli.ps1 create-site <domain.test> <relative_path_from_root>"
            exit 1
        }
        $Domain = $Arg1
        $ProjectPath = $Arg2
        $ConfigFile = "services/nginx/conf.d/$Domain.conf"

        if (Test-Path $ConfigFile) {
            Write-Error "Configuration for $Domain already exists."
            exit 1
        }

        $Content = @"
server {
    listen 80;
    listen 443 ssl;
    server_name $Domain;
    root /var/www/$ProjectPath;

    ssl_certificate /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    index index.php index.html;

    location / {
        try_files `$uri `$uri/ /index.php?`$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php85:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
        include fastcgi_params;
    }

    location ^~ /phpmyadmin/ {
        proxy_pass http://pma/;
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
    }
}
"@
        $Content | Out-File -FilePath $ConfigFile -Encoding UTF8
        Write-Host "✅ Configuration created: $ConfigFile"
        Write-Host "🔄 Restarting Nginx..."
        docker-compose restart nginx
        Write-Host "🎉 Done! Add '127.0.0.1 $Domain' to your hosts file."
    }

    "add-path" {
        if ([string]::IsNullOrEmpty($Arg1) -or [string]::IsNullOrEmpty($Arg2)) {
            Write-Host "Usage: ./cli.ps1 add-path <local_path> <container_folder_name>"
            exit 1
        }
        $LocalPath = $Arg1
        $ContainerName = $Arg2
        $OverrideFile = "docker-compose.override.yaml"
        $ExampleFile = "docker-compose.override.example.yaml"

        if (-not (Test-Path $OverrideFile)) {
            Copy-Item $ExampleFile $OverrideFile
        }

        $VolumeLine = "      - ${LocalPath}:/var/www/${ContainerName}"
        $FileContent = Get-Content $OverrideFile

        if ($FileContent -contains $VolumeLine.Trim()) {
            Write-Warning "This mapping already exists."
            exit
        }

        $NewContent = @()
        foreach ($Line in $FileContent) {
            if ($Line -match "# -- CUSTOM VOLUMES END --") {
                $NewContent += $VolumeLine
            }
            $NewContent += $Line
        }
        $NewContent | Set-Content $OverrideFile -Encoding UTF8
        Write-Host "✅ Added mapping."
        Write-Host "🔄 Recreating containers..."
        docker-compose up -d
    }

    "ssl-generate" {
        $CertDir = "certs"
        if (-not (Test-Path $CertDir)) { New-Item -ItemType Directory -Force -Path $CertDir | Out-Null }
        
        if (Get-Command openssl -ErrorAction SilentlyContinue) {
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
                -keyout "$CertDir\server.key" `
                -out "$CertDir\server.crt" `
                -subj "/C=TR/ST=Istanbul/L=Istanbul/O=Development/OU=Development/CN=*.test" `
                -addext "subjectAltName=DNS:*.test,DNS:localhost"
        } else {
            Write-Error "OpenSSL not found. Please install Git for Windows."
            exit 1
        }
        Write-Host "✅ Certificate generated."
    }

    "ssl-trust" {
        $CertFile = "certs\server.crt"
        if (-not (Test-Path $CertFile)) {
            Write-Error "Certificate not found."
            exit 1
        }
        Write-Host "🔑 Adding certificate to Trusted Root..."
        Import-Certificate -FilePath $CertFile -CertStoreLocation Cert:\CurrentUser\Root
        Write-Host "✅ Certificate trusted!"
    }

    Default {
        Write-Host "Unknown command: $Command"
        Show-Help
    }
}
