
                                                      
Clear-Host
Write-Host @"
  _    _                            _____  _____  
 | |  | |                          |  __ \|  __ \ 
 | |__| | ___  __ ___   _____ _ __ | |__) | |__) |
 |  __  |/ _ \/ _` \ \ / / _ \ '_ \|  _  /|  ___/ 
 | |  | |  __/ (_| |\ V /  __/ | | | | \ \| |     
 |_|  |_|\___|\__,_| \_/ \___|_| |_|_|  \_\_|     
                                                                                                                                             
"@ -ForegroundColor Cyan

Write-Host "Made by Mestervivo for Heaven RolePlay" 

$services = @('SysMain', 'PcaSvc', 'DPS', 'BAM', 'SgrmBroker', 'EventLog', 'Dnscache', 'Dhcp', 'WinDefend', 'Wecsvc',)

function Check-Services {
    Write-Output "`nHRP Service Checker" 
    foreach ($service in $services) {
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

            if ($isRunning) {
                Write-Host "- $service - Fut: Igen | Indítás Módja: $startTypeReadable" -ForegroundColor Green
            } else {
                Write-Host "- $service - Fut: Nem | Indítás Módja: $startTypeReadable" -ForegroundColor Red
            }
        } catch {
            Write-Output "- $service - Szolgáltatás nem található" -ForegroundColor Red
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