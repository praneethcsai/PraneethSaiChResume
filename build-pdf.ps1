# Regenerates Praneeth-Sai-Chunduru-Resume.pdf from index.html
# using the page's print styles. Run after every content change:
#   powershell -ExecutionPolicy Bypass -File build-pdf.ps1

$ErrorActionPreference = 'Stop'
$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw 'Chrome or Edge is required to build the PDF.' }

$page = Join-Path $PSScriptRoot 'index.html'
$out  = Join-Path $PSScriptRoot 'Praneeth-Sai-Chunduru-Resume.pdf'
$url  = 'file:///' + ($page -replace '\\', '/')

$tmp = Join-Path $env:TEMP 'resume-build.pdf'
if (Test-Path $tmp) { Remove-Item $tmp }
$profileDir = Join-Path $env:TEMP 'resume-pdf-profile'

# virtual-time-budget gives the web font time to load before printing
$chromeArgs = @('--headless', '--disable-gpu', '--no-first-run', '--no-pdf-header-footer',
  "--user-data-dir=`"$profileDir`"", '--virtual-time-budget=10000', "--print-to-pdf=`"$tmp`"", "`"$url`"")
Start-Process -FilePath $browser -ArgumentList $chromeArgs -Wait -WindowStyle Hidden `
  -RedirectStandardError (Join-Path $env:TEMP 'resume-pdf.log')

if (-not (Test-Path $tmp)) { throw 'PDF was not created.' }
try { Move-Item $tmp $out -Force }
catch { throw "Could not replace $out - close it in any PDF viewer and run again." }
Write-Host "Built $out"
