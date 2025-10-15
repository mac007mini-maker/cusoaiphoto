# ========================================
# Build Flutter App with ALL Ad Secrets
# For Windows PowerShell
# ========================================

param(
    [Parameter(Position=0)]
    [ValidateSet("apk", "appbundle", "ios")]
    [string]$BuildType = "apk"
)

Write-Host "======================================"
Write-Host "Building Flutter App with Ad Secrets"
Write-Host "Build Type: $BuildType"
Write-Host "======================================"

# Check if secrets.env exists
if (Test-Path "secrets.env") {
    Write-Host ""
    Write-Host "[OK] Loading secrets from secrets.env..."
    
    Get-Content "secrets.env" | ForEach-Object {
        if ($_ -match '^\s*export\s+(.+?)=(.+)$') {
            $varName = $matches[1].Trim()
            $varValue = $matches[2].Trim().Trim('"').Trim("'")
            [System.Environment]::SetEnvironmentVariable($varName, $varValue, "Process")
            Write-Host "  Loaded: $varName"
        }
    }
}
else {
    Write-Host ""
    Write-Host "[WARNING] secrets.env not found! Using environment variables..."
}

# Prepare dart-define arguments
$dartDefines = @()

# Check and add each secret
$secrets = @{
    "SUPABASE_URL" = $env:SUPABASE_URL
    "SUPABASE_ANON_KEY" = $env:SUPABASE_ANON_KEY
    "HUGGINGFACE_TOKEN" = $env:HUGGINGFACE_TOKEN
    "REPLICATE_API_TOKEN" = $env:REPLICATE_API_TOKEN
    "SUPPORT_EMAIL" = $env:SUPPORT_EMAIL
    "ADMOB_APP_ID" = $env:ADMOB_APP_ID
    "ADMOB_BANNER_AD_UNIT_ID" = $env:ADMOB_BANNER_AD_UNIT_ID
    "ADMOB_INTERSTITIAL_AD_UNIT_ID" = $env:ADMOB_INTERSTITIAL_AD_UNIT_ID
    "ADMOB_REWARDED_AD_UNIT_ID" = $env:ADMOB_REWARDED_AD_UNIT_ID
    "APPLOVIN_SDK_KEY" = $env:APPLOVIN_SDK_KEY
    "APPLOVIN_BANNER_AD_UNIT_ID" = $env:APPLOVIN_BANNER_AD_UNIT_ID
    "APPLOVIN_INTERSTITIAL_AD_UNIT_ID" = $env:APPLOVIN_INTERSTITIAL_AD_UNIT_ID
    "APPLOVIN_REWARDED_AD_UNIT_ID" = $env:APPLOVIN_REWARDED_AD_UNIT_ID
    "APPLOVIN_APP_OPEN_AD_UNIT_ID" = $env:APPLOVIN_APP_OPEN_AD_UNIT_ID
}

Write-Host ""
Write-Host "Checking secrets..."
foreach ($key in $secrets.Keys) {
    $value = $secrets[$key]
    if ($value) {
        $dartDefines += "--dart-define=$key=$value"
        Write-Host "  [OK] $key"
    }
    else {
        Write-Host "  [WARN] $key (missing - will use test ads)"
    }
}

# Build command based on type
Write-Host ""
Write-Host "Starting build..."

switch ($BuildType) {
    "apk" {
        Write-Host "Building Android APK..."
        flutter build apk --release $dartDefines
    }
    "appbundle" {
        Write-Host "Building Android App Bundle..."
        flutter build appbundle --release $dartDefines
    }
    "ios" {
        Write-Host "Building iOS..."
        flutter build ios --release $dartDefines
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[SUCCESS] Build completed successfully!"
    
    if ($BuildType -eq "apk") {
        Write-Host ""
        Write-Host "APK location:"
        Write-Host "  build\app\outputs\flutter-apk\app-release.apk"
        
        Write-Host ""
        Write-Host "Install with:"
        Write-Host "  adb install build\app\outputs\flutter-apk\app-release.apk"
    }
    elseif ($BuildType -eq "appbundle") {
        Write-Host ""
        Write-Host "App Bundle location:"
        Write-Host "  build\app\outputs\bundle\release\app-release.aab"
    }
}
else {
    Write-Host ""
    Write-Host "[ERROR] Build failed! Check errors above."
    exit 1
}
