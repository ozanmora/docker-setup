param (
    [string]$LocalPath,

    [string]$ContainerFolderName
)

if ([string]::IsNullOrEmpty($LocalPath) -or [string]::IsNullOrEmpty($ContainerFolderName)) {
    Write-Host "Usage: ./add-path.ps1 <local_path> <container_folder_name>"
    Write-Host "Example: ./add-path.ps1 ""C:\Users\username\Projects\example\laravel"" laravel-project"
    exit 1
}

$OverrideFile = "docker-compose.override.yaml"
$ExampleFile = "docker-compose.override.example.yaml"

# Create override file if not exists
if (-not (Test-Path $OverrideFile)) {
    Write-Host "Creating $OverrideFile from example..."
    Copy-Item $ExampleFile $OverrideFile
}

$VolumeLine = "      - ${LocalPath}:/var/www/${ContainerFolderName}"
$FileContent = Get-Content $OverrideFile

if ($FileContent -contains $VolumeLine.Trim()) {
    Write-Warning "This mapping already exists in $OverrideFile"
    exit
}

# Insert the line
$NewContent = @()
foreach ($Line in $FileContent) {
    if ($Line -match "# -- CUSTOM VOLUMES END --") {
        $NewContent += $VolumeLine
    }
    $NewContent += $Line
}

$NewContent | Set-Content $OverrideFile -Encoding UTF8

Write-Host "✅ Added mapping: $LocalPath -> /var/www/$ContainerFolderName"
Write-Host "🔄 Recreating containers to apply changes..."
docker-compose up -d
Write-Host "🎉 Done! Your project is mapped."
