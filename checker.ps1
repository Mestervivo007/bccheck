Clear-Host
Write-Host @"
  ____        _ _              ____            __ _   
 | __ )  __ _| | | _____ _ __ / ___|_ __ __ _ / _| |_ 
 |  _ \ / _` | | |/ / _ \ '__| |   | '__/ _` | |_| __|
 | |_) | (_| | |   <  __/ |  | |___| | | (_| |  _| |_ 
 |____/ \__,_|_|_|\_\___|_|   \____|_|  \__,_|_|  \__|
                                           
                                           
"@ -ForegroundColor Cyan

Write-Host "BalkerCraft SS-Tool" -ForegroundColor Yellow
Write-Host "Made by Mestervivo alias George for Balkercraft" -ForegroundColor Yellow

$services = @('SysMain', 'PcaSvc', 'DPS', 'BAM', 'SgrmBroker', 'EventLog')

function Is-Windows11 {
    $osVersion = (Get-ComputerInfo -Property "WindowsVersion").WindowsVersion
    return $osVersion -ge 22000
}

function Check-Services {
    Write-Output "`nSzolgáltatások ellenőrzése..." 
    $isWin11 = Is-Windows11

    foreach ($service in $services) {
        try {
            if ($isWin11 -and $service -eq 'SgrmBroker') {
                Write-Host "- $service - Szolgáltatás nem létezik (WIN11)" -ForegroundColor Yellow
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
        "C:\Users\$env:USERNAME\AppData\Roaming\ROCCAT\SWARM\"
    )

    $found = $false
    foreach ($directory in $directories) {
        if (Test-Path -Path $directory) {
            $found = $true
            $files = Get-ChildItem -Path $directory -File
            $modified = $false
            foreach ($file in $files) {
                if ($file.LastWriteTime -gt (Get-Date).AddMinutes(-30)) {
                    Write-Host "Egér program: $($directory) fájl módosítva: $($file.LastWriteTime)" -ForegroundColor Yellow
                    $modified = $true
                }
            }
            if (-not $modified) {
                Write-Host "Egér program: $($directory) Nem lett módosítva az elmúlt 30 percben" -ForegroundColor Green
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

    $filesToCheck = @("jnativehook*", "rar$ex*")
    $found = $false

    foreach ($filePattern in $filesToCheck) {
        $files = Get-ChildItem -Path $tempPath -Filter $filePattern -File -ErrorAction SilentlyContinue
        if ($files.Count -gt 0) {
            $found = $true
            foreach ($file in $files) {
                Write-Host "Fájl: $($file.FullName) | Módosítva: $($file.LastWriteTime)" -ForegroundColor Yellow
            }
        }
    }

    if (-not $found) {
        Write-Host "Nem található jnativehook vagy rar$ex fájl a temp mappában." -ForegroundColor Green
    }
}

function Run-ExternalScript {
    $scriptUrl = "https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1"
    Write-Output "BAM betöltése..." 
    powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; Invoke-Expression (Invoke-RestMethod $scriptUrl)"
}

function Show-Menu { 
    Write-Output "`nVálasztható opciók:"  
    Write-Output "1 - Kilépés" 
    Write-Output "2 - Szolgáltatások ellenőrzése" 
    Write-Output "3 - Szolgáltatások elindítása (Megpróbálása)" 
    Write-Output "4 - BAM futtatása" 
    Write-Output "5 - Egér program vizsgálata" 
    Write-Output "6 - Prefetch logok ellenőrzése"
} 

# Main loop to keep showing the menu and process multiple selections
do {
    Show-Menu
    $input = Read-Host "Válassz egy opciót: "
    
    switch ($input) {
        '2' { Check-Services }
        '3' { Enable-And-Start-Services }
        '4' { Run-ExternalScript }
        '5' { Check-MousePrograms }
        '6' { Check-PrefetchLogs }
        '1' { Write-Output "Kilépés..." }
        default { Write-Output "Ilyen lehetőség nincs koma" }
    }
} while ($input -ne '1')
