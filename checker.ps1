Clear-Host

function Test-Administrator {
    $isAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $isAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Is-Windows11 {
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $currentBuild = (Get-ItemProperty -Path $registryPath).CurrentBuild
    return [int]$currentBuild -ge 22000
}

if (-not (Test-Administrator)) {
    Write-Host "Mivan majom? csak nem megtaláltuk a github repot?" -ForegroundColor Red
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

$services = @('SysMain', 'PcaSvc', 'DPS', 'BAM', 'SgrmBroker', 'EventLog')

function Is-Windows11 {
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $currentBuild = (Get-ItemProperty -Path $registryPath).CurrentBuild
    return [int]$currentBuild -ge 22000
}

function Check-Services {
    Write-Output "`nSzolgáltatások ellenőrzése..." 
    $isWin11 = Is-Windows11

    foreach ($service in $services) {
        try {
            if ($isWin11 -and $service -eq 'SgrmBroker') {
                $serviceExists = Get-Service -Name $service -ErrorAction SilentlyContinue
                if ($null -eq $serviceExists) {
                    Write-Host "- $service - Szolgáltatás nem létezik (WIN11)" -ForegroundColor Yellow
                    continue
                }
            }

            $serviceObj = Get-Service -Name $service
            $startType = Get-CimInstance -ClassName Win32_Service -Filter "Name='$service'" | Select-Object -ExpandProperty StartMode

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
    Write-Host "`nEgér program vizsgálata..." -ForegroundColor Cyan
    $directories = @(
        "C:\Users\$env:USERNAME\AppData\local\BYCOMBO-2\",
        "C:\Users\$env:USERNAME\AppData\local\BY-COMBO2\",
        "C:\Users\$env:USERNAME\documents\ASUS\ROG\ROG Armoury\common\",
        "C:\Program Files (x86)\Bloody7\Bloody7\Data\Mouse\",
        "C:\Users\$env:USERNAME\appdata\corsair\CUE\",
        "C:\Users\$env:USERNAME\AppData\Local\LGHUB\",
        "C:\Users\$env:USERNAME\AppData\Local\Razer\",
        "C:\Users\$env:USERNAME\AppData\Roaming\ROCCAT\SWARM\",
        "C:\Program Files (x86)\Trust Gaming\",
        "C:\Program Files\SteelSeries\SteelSeries Engine\",
        "C:\Program Files (x86)\ZOWIE\",
        "C:\Program Files (x86)\A4Tech\Mouse\",
        "C:\Program Files\Cooler Master\Portal\",
        "C:\Program Files (x86)\MSI\Dragon Center\",
        "C:\Program Files (x86)\HyperX\Ngenuity\"
    )

    $found = $false
    foreach ($directory in $directories) {
        if (Test-Path -Path $directory) {
            $found = $true
            $files = Get-ChildItem -Path $directory -File
            $modified = $false
            foreach ($file in $files) {
                if ($file.LastWriteTime -gt (Get-Date).AddMinutes(-60)) {
                    Write-Host "Egér program: $($directory) fájl módosítva: $($file.LastWriteTime)" -ForegroundColor Yellow
                    $modified = $true
                }
            }
            if (-not $modified) {
                Write-Host "Egér program: $($directory) Nem lett módosítva az elmúlt 60 percben" -ForegroundColor Green
            }
        }
    }

    if (-not $found) {
        Write-Host "Egér program nem található vagy nincs telepítve" -ForegroundColor Red
    }
}

function Check-PrefetchLogs {
    Write-Host "`nPrefetch logok vizsgálata..." -ForegroundColor Cyan
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
        "https://github.com/Mestervivo007/bccheck/raw/main/USBDeview.exe",
        "https://github.com/Mestervivo007/bccheck/raw/main/WinPrefetchView.exe",
        "https://github.com/Mestervivo007/bccheck/raw/main/journal-tool.exe",
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
    Write-Host "`nMinecraft felhasználók összegyűjtése..." -ForegroundColor Cyan

    $cachePath = "$env:APPDATA\.minecraft\usercache.json"
    
    if (-Not (Test-Path $cachePath)) {
        Write-Host "Nem található usercache.json fájl" -ForegroundColor Red
        return
    }

    $cacheContent = Get-Content -Path $cachePath | ConvertFrom-Json
    $usernames = $cacheContent | ForEach-Object { $_.name }

    if ($usernames.Count -eq 0) {
        Write-Host "Nincsenek alternatív felhasználók" -ForegroundColor Green
    } else {
        Write-Host "EGYES KLIENS TÍPUSOKNÁL NEM MÜKÖDIK MEGFELELŐEN A USERCACHE! AMENNYIBEN TÖBB MINT 10 ALT TALÁLHATÓ BENNE NAGY ESÉLLYEL FALSE ADATOK!" -ForegroundColor Yellow
        Write-Host "`nAlternatív felhasználók:"
        foreach ($username in $usernames) {
            Write-Host "- $username" -ForegroundColor Yellow
        }
    }
}
function Check-Recording-Programs-Advanced {
    $recordingProcesses = @("obs", "bandicam", "nvspcapsvc", "fraps", "action", "mirillis", 
        "xsplit", "dxtory","nvidia shadowplay", "nvcontainer",
        "medal", "camtasia", "screenrec", "screencast-o-matic", "sharex",
        "debut", "flashback", "snagit", "icecream screen recorder",
        "loilo game recorder", "apowerrec", "movavi screen recorder")

    $allProcesses = Get-Process | Select-Object ProcessName, Id, Description, Path, WorkingSet64

    foreach ($process in $allProcesses) {
        if ($recordingProcesses -contains $process.ProcessName.ToLower()) {
            $memoryUsageMB = [math]::Round($process.WorkingSet64 / 1MB, 2)  
            if ($memoryUsageMB -ge 75) {  
                Write-Host "Felvétel aktív: $($process.ProcessName) | Útvonal: $($process.Path)" -ForegroundColor Red
            } 
        }
    }
}

Check-Recording-Programs-Advanced

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
        '1' { Write-Output "Kilépés..." }
        default { Write-Output "Ilyen lehetőség nincs koma" }
    }
} while ($input -ne '1')



