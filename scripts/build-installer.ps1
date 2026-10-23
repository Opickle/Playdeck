$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$OutputDirectory = Join-Path $ProjectRoot 'release'
$AppDirectory = Join-Path $OutputDirectory 'win-unpacked'
$BootstrapDirectory = Join-Path $OutputDirectory 'installer-build'
$Payload = Join-Path $BootstrapDirectory 'payload.zip'
$InstallerScript = Join-Path $BootstrapDirectory 'installer-ui.ps1'
$SedPath = Join-Path $BootstrapDirectory 'playdeck-installer.sed'
$Target = Join-Path $OutputDirectory 'Playdeck-Setup-1.0.0.exe'
if (-not (Test-Path (Join-Path $AppDirectory 'Playdeck.exe'))) { throw 'Packaged app not found. Run pnpm run dist:app first.' }
New-Item -ItemType Directory -Force -Path $BootstrapDirectory | Out-Null
if (Test-Path $Payload) { [System.IO.File]::Delete($Payload) }
Compress-Archive -Path (Join-Path $AppDirectory '*') -DestinationPath $Payload -CompressionLevel Fastest
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'installer-ui.ps1') -Destination $InstallerScript -Force
$source = $BootstrapDirectory.TrimEnd('\') + '\'
$sed = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles
[Strings]
InstallPrompt=Install Playdeck on this PC?
FinishMessage=Playdeck is installed. Your games and media are ready to add.
TargetName=$Target
FriendlyName=Playdeck Setup
AppLaunched=powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File installer-ui.ps1
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="installer-ui.ps1"
FILE1="payload.zip"
[SourceFiles]
SourceFiles0=$source
[SourceFiles0]
%FILE0%=
%FILE1%=
"@
Set-Content -LiteralPath $SedPath -Value $sed -Encoding Ascii
if (Test-Path $Target) { [System.IO.File]::Delete($Target) }
$iexpress = Join-Path $env:WINDIR 'System32\iexpress.exe'
$process = Start-Process -FilePath $iexpress -ArgumentList @('/N','/Q',$SedPath) -PassThru -Wait -WindowStyle Hidden
if ($process.ExitCode -ne 0 -or -not (Test-Path $Target)) { throw "IExpress failed to create $Target" }
Write-Output "Created $Target"
