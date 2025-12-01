param (
    [string]$Domain,

    [string]$ProjectPath
)

if ([string]::IsNullOrEmpty($Domain) -or [string]::IsNullOrEmpty($ProjectPath)) {
    Write-Host "Usage: ./create-site.ps1 <domain.test> <relative_path_from_root>"
    Write-Host "Example: ./create-site.ps1 laravel.test example/laravel/public"
    exit 1
}

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
}
"@

$Content | Out-File -FilePath $ConfigFile -Encoding UTF8

Write-Host "✅ Configuration created: $ConfigFile"
Write-Host "🔄 Restarting Nginx..."
docker-compose restart nginx
Write-Host "🎉 Done! Add '127.0.0.1 $Domain' to your hosts file and visit http://$Domain"
