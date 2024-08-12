Clear-Host
Write-Host @"
  ____        _ _              ____            __ _   
 | __ )  __ _| | | _____ _ __ / ___|_ __ __ _ / _| |_ 
 |  _ \ / _` | | |/ / _ \ '__| |   | '__/ _` | |_| __|
 | |_) | (_| | |   <  __/ |  | |___| | | (_| |  _| |_ 
 |____/ \__,_|_|_|\_\___|_|   \____|_|  \__,_|_|  \__|
                                           
                                           
"@ -ForegroundColor Cyan

Write-Host "Made by George for Balkercraft" 

$services = @('SysMain', 'PcaSvc', 'DPS', 'BAM', 'SgrmBroker', 'EventLog')

function Is-Windows11 {
    $osVersion = (Get-ComputerInfo -Property "WindowsVersion").WindowsVersion
    return $osVersion -ge 22000
}

function Get-LastStopTime {
    param (
        [string]$serviceName
    )
    $events = Get-WinEvent -LogName System -FilterHashtable @{ProviderName='Service Control Manager';Id=7036} -MaxEvents 1000 | 
        Where-Object { $_.Message -match "$serviceName.*leállítva"}
    
    if ($events) {
        return $events[0].TimeCreated
    }
    
    return $null
}

function Check-Services {
    Write-Output "`nBalkerCraft Service Checker" 
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
                $lastStopTime = Get-LastStopTime -serviceName $service
                if ($lastStopTime) {
                    Write-Host "  Utolsó leállítás időpontja: $lastStopTime" -ForegroundColor DarkYellow
                }
            }
        } catch {
            Write-Host "- $service - Szolgáltatás nem található" -ForegroundColor Red
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
    Write-Output "Szolgáltatások elindítása sikeresen megtörtént" 
}

Check-Services

function Run-ExternalScript {
    $scriptUrl = "https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1"
    Write-Output "BAM betöltése..." 
    powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; Invoke-Expression (Invoke-RestMethod $scriptUrl)"
}

Write-Output "`nTovábbi opciók: `n1 - Kilépés `n2 - Szolgáltatások elindítása(Megpróbálása) `n3 - BAM futtatása " 
$input = Read-Host

if ($input -eq '2') {
    Enable-And-Start-Services
} elseif ($input -eq '3') {
    Run-ExternalScript
} elseif ($input -ne '1') {
    Write-Output "Invalid input. Exiting."
}
