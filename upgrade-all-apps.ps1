# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch the script with elevated privileges
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# Proceed with the script after elevation
Write-Host "Script is running with administrative privileges." -ForegroundColor Green

# Get a list of upgradeable applications via Winget
Write-Host "Fetching list of upgradeable applications..." -ForegroundColor Cyan
$wingetOutput = winget upgrade | Out-String

# Parse the output to extract relevant rows
$parsedApps = @()
$wingetOutput -split "`n" | ForEach-Object {
    # Skip the header and separator rows
    if ($_ -match "Name\s+Id\s+Version\s+Available\s+Source" -or $_ -match "^-{10,}") { return }

    # Split each row into columns based on spacing
    $columns = $_ -split "\s{2,}"
    if ($columns.Length -ge 5) {
        $parsedApps += [PSCustomObject]@{
            Name       = $columns[0]
            Id         = $columns[1]
            Version    = $columns[2]
            Available  = $columns[3]
            Source     = $columns[4]
        }
    }
}

# Display the list as a formatted table
if ($parsedApps.Count -gt 0) {
    Write-Host "Upgradeable applications detected by Winget:" -ForegroundColor Green
    $parsedApps | Format-Table -Wrap -AutoSize | Out-String -Width 150 | Write-Host
} else {
    Write-Host "No upgradeable applications found." -ForegroundColor Yellow
    exit
}

# Prompt user before proceeding
$proceed = Read-Host "Do you want to update all apps? (Y/N)"
if ($proceed -notmatch "^[Yy]$") {
    Write-Host "Welp, my work is done here. Byeeee!!!" -ForegroundColor Red
    # Keep the terminal open for a moment before exiting
    Start-Sleep -Seconds 3
    exit
}

# Update all apps
Write-Host "Updating all upgradeable applications..." -ForegroundColor Cyan
try {
    winget upgrade --all --silent --include-unknown --accept-source-agreements --accept-package-agreements -e
    Write-Host "All updates completed successfully." -ForegroundColor Green
} catch {
    Write-Host "An error occurred during the update process: $($_.Exception.Message)" -ForegroundColor Red
}

# Prompt user with 'Werd' message at the end
$proceed = Read-Host "All good, chief? (Y/N)"
if ($proceed -eq "Y") {
    Write-Host "Sweet, enjoy your shiny new apps!" -ForegroundColor Yellow
} else {
    Write-Host "Welp, my work is done here. Byeeee" -ForegroundColor Red
}

# Keep the terminal open for a moment before exiting
Start-Sleep -Seconds 3
