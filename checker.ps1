Clear-Host

function Test-Administrator {
    $isAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $isAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}


if (-not (Test-Administrator)) {
    Write-Host "Mivan majom? Csak nem megtaláltuk a github repot?" -ForegroundColor Red
    sleep 5
    exit
}

Write-Host @"
  ____        _ _              ____            __ _   
 | __ )  __ _| | | _____ _ __ / ___|_ __ __ _ / _| |_ 
 |  _ \ / _` | | |/ / _ \ '__| |   | '__/ _` | |_| __|
 | |_) | (_| | |   <  __/ |  | |___| | | (_| |  _| |_ 
 |____/ \__,_|_|_|\_\___|_|   \____|_|  \__,_|_|  \__|
                                           
                                           
"@ -ForegroundColor Cyan

Write-Host "BalkerCraft SS-Tool" -ForegroundColor Yellow
Write-Host "Made by Mestervivo alias George for Balkercraft `n" -ForegroundColor Yellow

$services = @('SysMain', 'PcaSvc', 'DPS', 'BAM', 'SgrmBroker', 'EventLog', 'Dnscache')

function Is-Windows11 {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $currentVersion = (Get-ItemProperty -Path $regPath -Name CurrentBuild -ErrorAction Stop).CurrentBuild
    return $currentVersion -ge 22000
}

$services = @('SysMain', 'PcaSvc', 'DPS', 'BAM', 'SgrmBroker', 'EventLog', 'Dnscache')
$warningServices = @('Dhcp', 'WinDefend', 'Wecsvc')

function Check-Services {
    Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host   "║      Szolgáltatások ellenőrzése      ║" -ForegroundColor Cyan
    Write-Host   "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    $isWin11 = Is-Windows11

    foreach ($service in $services) {
        try {
            if ($isWin11 -and $service -eq 'SgrmBroker') {
                $serviceObj = Get-Service -Name $service -ErrorAction SilentlyContinue
                if ($serviceObj -and $serviceObj.Status -eq 'Running') {
                    Write-Host "- $service - Fut: Igen | Indítás Módja: $($serviceObj.StartType)" -ForegroundColor Green
                } else {
                    Write-Host "- $service - Fut: Nem | Indítás Módja: $($serviceObj.StartType) | Figyelmenkívül hagyva (WIN11)" -ForegroundColor Yellow
                }
                continue
            }

            $serviceObj = Get-Service -Name $service
            $startType = Get-WmiObject -Class Win32_Service -Filter "Name='$service'" | Select-Object -ExpandProperty StartMode

            $status = $serviceObj.Status
            $isRunning = $status -eq 'Running'
            $startTypeReadable = switch ($startType) {
                'Auto' { 'Automatic' }
                'Manual' { 'Manual' }
                'Disabled' { 'Disabled' }
                default { 'Unknown' }
            }

            if ($isRunning) {
                Write-Host "- $service - Fut: Igen | Indítás Módja: $startTypeReadable" -ForegroundColor Green
            } else {
                Write-Host "- $service - Fut: Nem | Indítás Módja: $startTypeReadable" -ForegroundColor Red
            }
        } catch {
            Write-Host "- $service - Szolgáltatás nem található" -ForegroundColor Red
        }
    }

    foreach ($service in $warningServices) {
        try {
            $serviceObj = Get-Service -Name $service
            $startType = Get-WmiObject -Class Win32_Service -Filter "Name='$service'" | Select-Object -ExpandProperty StartMode

            $status = $serviceObj.Status
            $isRunning = $status -eq 'Running'
            $startTypeReadable = switch ($startType) {
                'Auto' { 'Automatic' }
                'Manual' { 'Manual' }
                'Disabled' { 'Disabled' }
                default { 'Unknown' }
            }

            Write-Host "- $service - Fut: $(if ($isRunning) {'Igen'} else {'Nem'}) | Indítás Módja: $startTypeReadable" -ForegroundColor Yellow

        } catch {
            Write-Host "- $service - Szolgáltatás nem található" -ForegroundColor Yellow
        }
    }

    Check-Process-Uptime -ProcessName "javaw" -AltProcessName "java"
    Check-Process-Uptime -ProcessName "explorer"
}



function Check-Process-Uptime {
    param (
        [string]$ProcessName,
        [string]$AltProcessName = $null
    )

    try {
        $process = Get-Process -Name $ProcessName -ErrorAction Stop
        $startTime = $process.StartTime
        $uptime = New-TimeSpan -Start $startTime -End (Get-Date)
        Write-Host "- $ProcessName.exe futási idő: $($uptime.Days) nap $($uptime.Hours) óra $($uptime.Minutes) perc" -ForegroundColor Cyan
    } catch {
        if ($AltProcessName) {
            try {
                $altProcess = Get-Process -Name $AltProcessName -ErrorAction Stop
                $startTime = $altProcess.StartTime
                $uptime = New-TimeSpan -Start $startTime -End (Get-Date)
                Write-Host "- $AltProcessName.exe futási idő: $($uptime.Days) nap $($uptime.Hours) óra $($uptime.Minutes) perc" -ForegroundColor Cyan
            } catch {
                Write-Host " Minecraft nincs elindítva vagy a kliens egyedi" -ForegroundColor Red
            }
        } else {
            Write-Host "- $ProcessName.exe nem fut" -ForegroundColor Red
        }
    }
}

function Enable-And-Start-Services {
    foreach ($service in $services) {
        try {
            Set-Service -Name $service -StartupType Automatic
            Start-Service -Name $service -ErrorAction SilentlyContinue
        } catch {
            Write-Output "Nem sikerült elindítani a(z) $service szolgáltatást" 
        }
    }
    Write-Output "Szolgáltatások elindításának próbája sikeresen megtörtént" 
}

function Check-MousePrograms {
    Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host   "║        Egér program vizsgálata       ║" -ForegroundColor Cyan
    Write-Host   "╚══════════════════════════════════════╝" -ForegroundColor Cyan
$directories = @(
    # Glorious régi
    "C:\Users\$env:USERNAME\AppData\local\BYCOMBO-2\",
    "C:\Users\$env:USERNAME\AppData\local\BY-COMBO2\",
    "C:\Users\$env:USERNAME\AppData\Local\BYCOMBO2\mac\",
    "C:\Users\$env:USERNAME\AppData\Local\BY-COMBO\",
    
    # Glorious Core új
    "C:\ProgramData\Glorious Core\userdata\guru\data\",
    "C:\Users\$env:USERNAME\AppData\Local\Glorious\",
    
    # ASUS / Armoury Crate
    "C:\Users\$env:USERNAME\documents\ASUS\ROG\ROG Armoury\common\",
    "C:\Program Files\ASUS\Armoury Crate\",
    
    # A4Tech / Bloody / Oscar
    "C:\Program Files (x86)\Bloody7\Bloody7\Data\Mouse\",
    "C:\Program Files (x86)\Oscar Mouse Editor\",
    "C:\Program Files (x86)\A4Tech\Mouse\",
    
    # Corsair
    "C:\Users\$env:USERNAME\appdata\corsair\CUE\",
    "C:\Program Files (x86)\Corsair\Corsair Utility Engine\",
    "C:\Program Files\Corsair\iCUE\",

    # Logitech
    "C:\Users\$env:USERNAME\AppData\Local\LGHUB\",
    "C:\Program Files\Logitech Gaming Software\",
    
    # Razer
    "C:\Users\$env:USERNAME\AppData\Local\Razer\",
    "C:\Program Files (x86)\Razer\Synapse\",
    
    # Roccat
    "C:\Users\$env:USERNAME\AppData\Roaming\ROCCAT\SWARM\",
    
    # SteelSeries
    "C:\Program Files (x86)\SteelSeries\SteelSeries Engine\",
    "C:\Program Files\SteelSeries\SteelSeries Engine\",
    "C:\Program Files\SteelSeries\GG\",
    
    # Cooler Master
    "C:\Program Files\Cooler Master\Portal\",

    # MSI
    "C:\Program Files (x86)\MSI\Dragon Center\",

    # HyperX
    "C:\Program Files (x86)\HyperX\Ngenuity\",

    # Redragon
    "C:\Users\$env:USERNAME\AppData\Roaming\REDRAGON\GamingMouse\",
    "C:\Users\$env:USERNAME\Documents\M711\",

    # Trust Gaming
    "C:\Program Files (x86)\Trust Gaming\",

    # ZOWIE
    "C:\Program Files (x86)\ZOWIE\",

    # Fantech
    "C:\Program Files (x86)\FANTECH VX7 Gaming Mouse\",

    # Blackweb
    "C:\Blackweb Gaming AP\",

    # Noname/Generic kínai driverek (pl. „Driver Nombredemouse”)
    "C:\Program Files (x86)\Driver Nombredemouse\INI_CN\",
    "C:\Program Files (x86)\Driver Nombredemouse\INI_EN\",

    # Lehetséges saját user script helyek
    "C:\Users\$env:USERNAME\AppData\Roaming\MouseMacros\",
    "C:\Users\$env:USERNAME\Documents\Mouse Scripts\"
)


    $found = $false
    foreach ($directory in $directories) {
        if (Test-Path -Path $directory) {
            $found = $true
            $files = Get-ChildItem -Path $directory -File
            $modified = $false
            foreach ($file in $files) {
                if ($file.LastWriteTime -gt (Get-Date).AddMinutes(-120)) {
                    Write-Host "Egér program: $($directory) fájl módosítva: $($file.LastWriteTime)" -ForegroundColor Yellow
                    $modified = $true
                }
            }
            if (-not $modified) {
                Write-Host "Egér program: $($directory) Nem lett módosítva az elmúlt 120 percben" -ForegroundColor Green
            }
        }
    }

    if (-not $found) {
        Write-Host "Egér program nem található vagy nincs telepítve" -ForegroundColor Red
    }
}

function Check-PrefetchLogs {
    Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host   "║      Prefetch logok vizsgálata       ║" -ForegroundColor Cyan
    Write-Host   "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    $tempPath = [System.IO.Path]::GetTempPath()

    $filesToCheck = @("JNativeHook*", "rar$ex*", "autoclicker.exe", "autoclicker", "AC.exe", "AC", "1337clicker.exe")
    $found = $false

    foreach ($filePattern in $filesToCheck) {
        $files = Get-ChildItem -Path $tempPath -Recurse -Filter $filePattern -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            Write-Host "Log fájl: $($file.FullName)" -ForegroundColor Yellow
            $found = $true
        }
    }

    if (-not $found) {
        Write-Host "Nincs gyanús fájl a temp mappában" -ForegroundColor Green
    }
}

function Run-ExternalScript {
    $scriptUrl = "https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1"
    Write-Output "BAM betöltése..." 
    powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; Invoke-Expression (Invoke-RestMethod $scriptUrl)"
}

function Download-SSPrograms {
    Write-Host "`nSS programok letöltése..." -ForegroundColor Cyan
    
    $urls = @(
        "https://github.com/Mestervivo007/bccheck/raw/main/WinPrefetchView.exe",
        "https://github.com/Mestervivo007/bccheck/raw/main/procexp.exe",   
        "https://github.com/Mestervivo007/bccheck/raw/main/echo-journal.exe", 
        "https://github.com/Mestervivo007/bccheck/raw/main/echo-usb.exe", 
        "https://github.com/Mestervivo007/bccheck/raw/main/echo-userassist.exe", 
        "https://github.com/Mestervivo007/bccheck/raw/main/Everything-1.4.1.1022.x64-Setup.exe"
    )

    $destinationFolder = "$env:USERPROFILE\Downloads\SS-Tools"

    if (-not (Test-Path $destinationFolder)) {
        New-Item -ItemType Directory -Path $destinationFolder | Out-Null
    }

    foreach ($url in $urls) {
        $fileName = [System.IO.Path]::GetFileName($url)
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath $fileName
        Invoke-WebRequest -Uri $url -OutFile $destinationPath
        Write-Host "Letöltve: $fileName" -ForegroundColor Green
    }
}

function Get-MinecraftAlts {
    Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host   "║ Minecraft felhasználók összegyűjtése ║" -ForegroundColor Cyan
    Write-Host   "╚══════════════════════════════════════╝" -ForegroundColor Cyan

    # Lunar Client
    $lunarPath = "C:\Users\$env:USERNAME\.lunarclient\settings\game\accounts.json"
    if (Test-Path $lunarPath) {
        Write-Host "==Lunar Accounts==" -ForegroundColor Magenta
        Get-Content $lunarPath | Select-String -Pattern "username" | ForEach-Object { Write-Host $_.Line -ForegroundColor Yellow }
    }
    # .minecraft (usercache.json)
    $minecraftCachePath = "$env:APPDATA\.minecraft\usercache.json"
    if (Test-Path $minecraftCachePath) {
        Write-Host "==minecraft Accounts==" -ForegroundColor Magenta
        $minecraftData = Get-Content $minecraftCachePath | ConvertFrom-Json
        $minecraftData | ForEach-Object { Write-Host "- " $_.name -ForegroundColor Yellow }
        Write-Host "LEHETSÉGES FALSE ADATOK!" -ForegroundColor Yellow
    }

    # Cosmic Client
    $cosmicPath = "$env:APPDATA\.minecraft\cosmic\accounts.json"
    if (Test-Path $cosmicPath) {
        Write-Host "==Cosmic Client Accounts==" -ForegroundColor Magenta
        Get-Content $cosmicPath | Select-String -Pattern "displayName" | ForEach-Object { Write-Host $_.Line -ForegroundColor Yellow }
    }

    # TLauncher (legacy és új)
    $tlauncherLegacyPath = "$env:APPDATA\.tlauncher\legacy\Minecraft\game\tlauncher_profiles.json"
    $tlauncherPath = "$env:APPDATA\.minecraft\TlauncherProfiles.json"
    if (Test-Path $tlauncherLegacyPath) {
        Write-Host "==TLauncher Accounts==" -ForegroundColor Magenta
        Get-Content $tlauncherLegacyPath | Select-String -Pattern "username" | ForEach-Object { Write-Host $_.Line -ForegroundColor Yellow }
    }
    if (Test-Path $tlauncherPath) {
        Write-Host "==TLauncher Accounts==" -ForegroundColor Magenta
        Get-Content $tlauncherPath | Select-String -Pattern "displayName" | ForEach-Object { Write-Host $_.Line -ForegroundColor Yellow }
    }

    # Orbit Launcher
    $orbitPath = "$env:APPDATA\Orbit-Launcher\launcher-minecraft\cachedImages\faces\"
    if (Test-Path $orbitPath) {
        Write-Host "==Orbit Accounts==" -ForegroundColor Magenta
        Get-ChildItem -Path $orbitPath -Filter "*.png" | ForEach-Object { Write-Host $_.BaseName -ForegroundColor Yellow }
    }

    # Badlion Client
    $badlionPath = "$env:APPDATA\Badlion Client\logs\launcher"
    if (Test-Path $badlionPath) {
        Write-Host "==Badlion Accounts==" -ForegroundColor Magenta
        Get-ChildItem -Path $badlionPath -Recurse -File | ForEach-Object {
            $lines = Select-String -Path $_.FullName -Pattern "Found user"
            foreach ($line in $lines) {
                $line -match "Found user: (.+)$"
                if ($matches[1]) {
                    Write-Host $matches[1] -ForegroundColor Yellow
                }
            }
        }
    }

    Write-Host "`nEllenőrzés befejezve." -ForegroundColor Cyan
}





function Record-VPN-Checker {

    $recordingProcesses = @(
        'mirillis', 'wmcap', 'playclaw', 'XSplit', 'Screencast', 'camtasia', 'dxtory', 'nvcontainer', 'obs64',
        'bdcam', 'RadeonSettings', 'Fraps', 'CamRecorder', 'XSplit.Core', 'ShareX', 'Action', 'lightstream',
        'streamlabs', 'webrtcvad', 'openbroadcastsoftware', 'movavi.screen.recorder', 'icecreamscreenrecorder', 'Medal'
    )

    foreach ($process in $recordingProcesses) {
        try {
            $proc = Get-Process -Name $process -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "- Lehetséges képernyő rögzítés | $process " -ForegroundColor Red
            }
        } catch {
            Write-Host "- $process nem fut." -ForegroundColor Green
        }
    }

    $vpnProcesses = @(
        'pia-client', 'ProtonVPNService', 'IpVanish', 'WindScribe', 'ExpressVPN', 'NordVPN',
        'CyberGhost', 'pia-tray', 'SurfShark', 'VyprVPN', 'HSSCP', 'TunnelBear', 'ProtonVPN'
    )

    foreach ($process in $vpnProcesses) {
        try {
            $proc = Get-Process -Name $process -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "- VPN | $process" -ForegroundColor Red
            }
        } catch {
            Write-Host "- $process nem fut." -ForegroundColor Green
        }
    }
}

function Check-DevTools-Last60Min {
    $startTime = (Get-Date).AddMinutes(-120)

    $trackedApps = @(
        "python.exe", "py.exe", "code.exe", "idea64.exe", "clion64.exe",
        "pycharm64.exe", "webstorm64.exe", "datagrip64.exe", "Anydesk2.exe"
    )

    $prefetchPath = "C:\Windows\Prefetch"

    Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host   "║    Gyanús fejlesztői tevékenység     ║" -ForegroundColor Cyan
    Write-Host   "╚══════════════════════════════════════╝" -ForegroundColor Cyan

    if (-not (Test-Path $prefetchPath)) {
        Write-Host " A Prefetch mappa nem elérhető. Futtasd a scriptet rendszergazdaként!" -ForegroundColor Red
        return
    }

    $found = $false
    $recentPrefetch = Get-ChildItem -Path $prefetchPath -Filter "*.pf" | Where-Object {
        $_.LastWriteTime -gt $startTime
    }

    foreach ($item in $recentPrefetch) {
        $fileName = $item.Name
        foreach ($app in $trackedApps) {
            if ($fileName -match [regex]::Escape($app)) {
                $timeStr = $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                Write-Host " $app indítva: $timeStr" -ForegroundColor Yellow
                $found = $true
            }
        }
    }

    if (-not $found) {
        Write-Host " Nem indult fejlesztői alkalmazás az elmúlt 120 percben." -ForegroundColor Green
    }
}

function Check-AntiTampering {


    $hostname = $env:COMPUTERNAME
    $regOwner = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").RegisteredOwner
    Write-Host "Számitógép: $hostname" -ForegroundColor Gray
    Write-Host "Fiók: $regOwner" -ForegroundColor Gray

    $biosInfo = Get-WmiObject Win32_BIOS
    if ($biosInfo.SerialNumber -match "Default|To be filled|123456|0000|OEM") {
        Write-Host "BIOS Serial gyanús: $($biosInfo.SerialNumber)" -ForegroundColor Yellow
    } else {
        Write-Host "BIOS Serial: $($biosInfo.SerialNumber)" -ForegroundColor Green
    }

    
    Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.MACAddress -ne $null} | ForEach-Object {
        if ($_.MACAddress -match "^00|^FF") {
            Write-Host "Gyanús MAC Address: $($_.MACAddress)" -ForegroundColor Yellow
        }
    }
}
function Write-SectionHeader {
    param (
        [string]$Title
    )

    $line = "═" * ($Title.Length + 4)
    Write-Host "`n╔$line╗" -ForegroundColor Cyan
    Write-Host "║  $Title  ║" -ForegroundColor Cyan
    Write-Host "╚$line╝" -ForegroundColor Cyan
}

function  Detect-AutoHotKey {
    $ahkProcesses = Get-Process | Where-Object { $_.Name -like "*ahk*" -or $_.Path -like "*.ahk" }
    if ($ahkProcesses) {
        foreach ($proc in $ahkProcesses) {
            Write-Host " AutoHotKey gyanús processz: $($proc.Name)" -ForegroundColor Red
        }
    }

    $ahkFiles = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -Include *.ahk -ErrorAction SilentlyContinue
    if ($ahkFiles.Count -gt 0) {
        foreach ($file in $ahkFiles) {
            Write-Host "Talált AHK fájl: $($file.FullName)" -ForegroundColor Red
        }
    } 
}

function Check-SuspiciousStartup {
    Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host   "║    Startup Programok ellenőrzése     ║" -ForegroundColor Cyan
    Write-Host   "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    $startupPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    foreach ($path in $startupPaths) {
        try {
            if (Test-Path $path) {
                Get-ItemProperty -Path $path | ForEach-Object {
                    foreach ($property in $_.PSObject.Properties) {
                        if ($property.Name -ne "PSPath" -and $property.Value) {
                            Write-Host ": $($property.Name) = $($property.Value)" -ForegroundColor Yellow
                        }
                    }
                }
            }
        } catch {
            Write-Host " Nem sikerült elérni: $path" -ForegroundColor Red
        }
    }
}

function Hunt-RegistryKeys {

$suspiciousKeys = @(
    # Cheat Engine
    "HKCU:\Software\Cheat Engine",
    "HKLM:\Software\Cheat Engine",
    "HKCU:\Software\CheatEngine",
    "HKLM:\Software\CheatEngine",

    # Autoclickerek
    "HKCU:\Software\AutoHotkey",
    "HKLM:\Software\AutoHotkey",
    "HKCU:\Software\autoclicker",
    "HKCU:\Software\autoclicke",
    "HKCU:\Software\AutoClick",
    "HKCU:\Software\GS Auto Clicker",
    "HKCU:\Software\OP Auto Clicker",
    "HKCU:\Software\SpeedAutoClicker",

    #  Kliensek
    "HKCU:\Software\vape",
    "HKCU:\Software\VapeV4",
    "HKCU:\Software\VapeV2",
    "HKCU:\Software\Aristois",
    "HKCU:\Software\LunarClient\mods",
    "HKCU:\Software\Impact",
    "HKCU:\Software\Wurst",

    # Autoclickerek
    "HKCU:\Software\JNativeHook",
    "HKCU:\Software\JInput",
    "HKCU:\Software\JNIGameHook",
    "HKCU:\Software\A4Tech",
    "HKLM:\SYSTEM\CurrentControlSet\Services\HIDMacros",
    "HKCU:\Software\Interception",
    "HKCU:\Software\InterceptionDriver",
    "HKCU:\Software\mousehook",
    "HKCU:\Software\Rewasd",
    "HKCU:\Software\InputMapper",
    "HKCU:\Software\DS4Windows",

    # Java injector 
    "HKCU:\Software\JavaInjector",
    "HKCU:\Software\MinecraftHack",
    "HKCU:\Software\MinecraftInjector",

    # DLL injector
    "HKCU:\Software\Extreme Injector",
    "HKCU:\Software\GH Injector",
    "HKCU:\Software\DLLInjector",
    "HKCU:\Software\Process Hacker",
    "HKCU:\Software\ProtonVPN", 

    # Egyéb 
    "HKCU:\Software\AimAssist",
    "HKCU:\Software\TriggerBot",
    "HKCU:\Software\HackTool",
    "HKCU:\Software\MacroRecorder"
)


    foreach ($key in $suspiciousKeys) {
        if (Test-Path $key) {
            Write-Host "Gyanús registry kulcs találat: $key" -ForegroundColor Red
        }
    }
}



Write-SectionHeader "Általános lekérdezések indítása"
Check-AntiTampering
Detect-AutoHotKey
Hunt-RegistryKeys
Record-VPN-Checker
Check-DevTools-Last60Min


function Write-InfoLine {
    param(
        [string]$Text,
        [string]$Icon = "🔹",
        [string]$Color = "White"
    )
    Write-Host "$Icon $Text" -ForegroundColor $Color
}



function Show-Menu { 
    Write-Output "`nVálasztható opciók:"  
    Write-Output "1 - Kilépés" 
    Write-Output "2 - Szolgáltatások ellenőrzése" 
    Write-Output "3 - Szolgáltatások elindítása (Megpróbálása)" 
    Write-Output "4 - BAM futtatása" 
    Write-Output "5 - Egér program vizsgálata" 
    Write-Output "6 - Prefetch logok ellenőrzése"
    Write-Output "7 - SS programok letöltése"
    Write-Output "8 - Minecraft karakterek lekérése"
    Write-Output "9 - Általános ellenőrzés"
    Write-Output "10 - Automatikusan elindult alkalmazások (IN DEVELOPMENT)"
} 

do {
    Show-Menu
    $input = Read-Host "Válassz egy opciót: "
    
    switch ($input) {
        '2' { Check-Services }
        '3' { Enable-And-Start-Services }
        '4' { Run-ExternalScript }
        '5' { Check-MousePrograms }
        '6' { Check-PrefetchLogs }
        '7' { Download-SSPrograms }
        '8' { Get-MinecraftAlts }
        '9' { Record-VPN-Checker }
        '10' { Check-SuspiciousStartup }
        '1' { Write-Output "Kilépés..." }
        default { Write-Output "Ilyen lehetőség nincs koma" }
    }
} while ($input -ne '1')


