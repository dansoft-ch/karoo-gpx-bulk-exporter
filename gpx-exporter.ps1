# ==============================
# CONFIGURATION
# ==============================

$BaseUrl      = "https://dashboard.hammerhead.io/v1"
$UserId       = $env:KAROO_USER_ID
$BearerToken  = $env:KAROO_TOKEN

$OutputFolder = ".\HammerheadRoutes"
$PerPage      = 50

# Create output folder if needed
if (!(Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

# ==============================
# SESSION + HEADERS
# ==============================

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

$Headers = @{
    "Authorization" = "Bearer $BearerToken"
    "Accept"        = "*/*"
    "Referer"       = "https://dashboard.hammerhead.io/routes"
}

# ==============================
# HELPER: MAP CONTENT-TYPE TO EXTENSION
# ==============================

function Get-ExtensionFromContentType {
    param($ContentType)

    switch -Wildcard ($ContentType) {
        "application/gpx+xml*"  { return "gpx" }
        "application/xml*"      { return "xml" }
        "application/json*"     { return "json" }
        "application/zip*"      { return "zip" }
        "application/octet-stream*" { return "bin" }
        "text/xml*"             { return "xml" }
        "text/plain*"           { return "txt" }
        default                 { return "dat" }
    }
}

# ==============================
# GET ALL ROUTES (PAGINATED)
# ==============================

$page = 1
$allRoutes = @()

do {
    Write-Host "Fetching page $page..."

    $uri = "$BaseUrl/users/$UserId/routes?per_page=$PerPage&page=$page&order_by=NEWEST&ascending=true&exclude=archive"

    $response = Invoke-RestMethod `
        -Uri $uri `
        -Method Get `
        -WebSession $session `
        -Headers $Headers

    if ($response.data) {
        $allRoutes += $response.data
    }

    $hasMore = ($response.data.Count -eq $PerPage)
    $page++

} while ($hasMore)

Write-Host "Total routes found: $($allRoutes.Count)"

# ==============================
# DOWNLOAD + SAVE RAW RESPONSE
# ==============================

foreach ($route in $allRoutes) {

    $routeId   = $route.id
    $routeName = $route.name
    $safeName  = ($routeName -replace '[\\/:*?"<>|]', '_')
    $filePath  = Join-Path $OutputFolder "$safeName.gpx"

    $exportUrl = "$BaseUrl/users/$UserId/routes/$routeId/export?format=gpx"

    Write-Host "Downloading: $routeName"

    try {
        Invoke-WebRequest `
            -Uri $exportUrl `
            -WebSession $session `
            -Headers $Headers `
            -OutFile $filePath `
            -ErrorAction Stop

        Write-Host "Saved: $filePath"
    }
    catch {
        Write-Warning "Failed to download $routeName"
        Write-Warning $_.Exception.Message
    }
}

Write-Host "All routes downloaded."
