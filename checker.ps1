
                                                      
Clear-Host
Write-Host @"
  ____        _ _              ____            __ _   
 | __ )  __ _| | | _____ _ __ / ___|_ __ __ _ / _| |_ 
 |  _ \ / _` | | |/ / _ \ '__| |   | '__/ _` | |_| __|
 | |_) | (_| | |   <  __/ |  | |___| | | (_| |  _| |_ 
 |____/ \__,_|_|_|\_\___|_|   \____|_|  \__,_|_|  \__|
                                           
                                           
"@ -ForegroundColor Cyan

Write-Host "Made by George for Balkercraft" -ForegroundColor yellow `n

$services = @('SysMain', 'PcaSvc', 'DPS', 'BAM', 'SgrmBroker', 'EventLog')

function Check-Services {
    Write-Output "BalkerCraft Service Checker" -ForegroundColor Cyan
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
                Write-Host "- $service - Running: True StartType: $startTypeReadable" -ForegroundColor Green
            } else {
                Write-Host "- $service - Running: False StartType: $startTypeReadable" -ForegroundColor Red
            }
        } catch {
            Write-Output "- $service - Service not found" -ForegroundColor Red
        }
    }
}

function Enable-And-Start-Services {
    foreach ($service in $services) {
        try {
            Set-Service -Name $service -StartupType Automatic
            Start-Service -Name $service -ErrorAction SilentlyContinue
        } catch {
            Write-Output "Failed to enable or start $service" 
        }
    }
    Write-Output "All services have been set to start automatically and started if not already running."
}

Check-Services

function Run-ExternalScript {
    $scriptUrl = "https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1"
    Write-Output "BAM betöltése..." -ForegroundColor Cyan
    powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; Invoke-Expression (Invoke-RestMethod $scriptUrl)"
}

Write-Output "`nTovábbi opciók: `n1 - Kilépés `n2 - Szolgáltatások elindítása(Megpróbálása) `n3 - BAM futtatása " -ForegroundColor Cyan
$input = Read-Host

if ($input -eq '2') {
    Enable-And-Start-Services
} elseif ($input -eq '3') {
    Run-ExternalScript
} elseif ($input -ne '1') {
    Write-Output "Invalid input. Exiting."
}