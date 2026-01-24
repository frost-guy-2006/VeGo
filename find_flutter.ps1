$paths = @('C:\src\flutter', 'C:\flutter', 'D:\flutter', 'D:\src\flutter', "$env:USERPROFILE\flutter", 'C:\tools\flutter');
$found = $false
foreach ($p in $paths) {
    $binPath = Join-Path $p "bin\flutter.bat"
    if (Test-Path $binPath) {
        Write-Output "Found Flutter at: $p"
        $found = $true
    }
}

if (-not $found) {
    Write-Output "Flutter not found in common locations."
    # Check if winget is available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Output "Winget is available."
    } else {
        Write-Output "Winget is NOT available."
    }
}
