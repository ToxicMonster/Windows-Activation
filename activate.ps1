param (
    [string]$GVLK,
    [string]$KMS,
    [switch]$OVERWRITE
)

if ($GVLK) {
    $GVLK_FILE = $GVLK
    Write-Host "GVLK File: $GVLK"
    $GVLK_FILE = Get-Content -Path $GVLK_FILE | ConvertFrom-Json
}
else {
    $GVLK_FILE = Invoke-WebRequest "https://raw.githubusercontent.com/ToxicMonster/Windows-Activation/main/config/gvlk.json" | ConvertFrom-Json
    Write-Host "GVLK File: Default"
}

if ($KMS) {
    $KMS_SERVER = $KMS
}
else {
    $KMS_SERVER = "kms.toxicmonster.net"
}
Write-Host "KMS Server: $KMS_SERVER"

Write-Host "Overwrite Current Key: $OVERWRITE"

function Get-WindowsSKU {
    $osName = (Get-ComputerInfo).WindowsProductName
    $sku = ($osName -split ':')[-1].Trim()
    Write-Host "Product SKU: $sku"
    return $sku
}

function Get-ProductKey($sku) {
    $productKey = $GVLK_FILE.$sku
    if ($productKey) {
        Write-Host "Product Key: $productKey"
    }
    else {
        Write-Error "No product key found for $sku"
        exit
    }
    return $productKey
}

function Get-ActivationStatus {
    $activationStatus = (Get-WmiObject -Query 'SELECT * FROM SoftwareLicensingProduct' | Where-Object { $_.PartialProductKey -ne $null }).LicenseStatus
    if ($activationStatus -eq 1) {
        Write-Host "Current Activation Status: Activated"
        return $true
    } elseif ($activationStatus -eq 2) {
        Write-Host "Current Activation Status: Not Activated"
        return $false
    } elseif ($activationStatus -eq 3) {
        Write-Host "Current Activation Status: Not Activated - Notification Period"
        return $false
    } elseif ($activationStatus -eq 4) {
        Write-Host "Current Activation Status: Not Activated - Extended Grace Period"
        return $false
    } elseif ($activationStatus -eq 5) {
        Write-Host "Current Activation Status: Not Genuine"
        return $false
    } else {
        Write-Host "Current Activation Status: Error"
        return $null
    }
}

function Invoke-Activation($currentStatus, $productKey) {
    if (!(($OVERWRITE -eq $false) -and ($currentStatus -eq $true))) {
        Write-Warning "Activating Windows with product key $productKey on server $KMS_SERVER"
        cscript.exe C:\Windows\System32\slmgr.vbs /ipk $productKey
        cscript.exe C:\Windows\System32\slmgr.vbs /skms $KMS_SERVER
        cscript.exe C:\Windows\System32\slmgr.vbs /ato
        if (Get-ActivationStatus) {
            Write-Host "Windows activated successfully with product key $productKey"
        }
        else {
            Write-Error "An unknown error occurred activating Windows with product key $productKey"
        }
    }
    else {
        Write-Error "Windows is Already Activated!"
    }
}

$currentStatus = Get-ActivationStatus
$sku = Get-WindowsSKU
$productKey = Get-ProductKey $sku
Invoke-Activation $currentStatus $productKey