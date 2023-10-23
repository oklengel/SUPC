param (
    [Parameter(Mandatory=$true)]
    [string]$xmlFilePath
)

# XML-Datei laden
[xml]$xml = Get-Content $xmlFilePath

# Nutzername und Domain aus der XML-Datei lesen
# Benutzerinformationen abrufen
$username = $xml.Root.User.Username
$domain = $xml.Root.User.Domain
#Write-Host "Benutzername: $username, Domäne: $domain"
Write-Host "Let's setup a pc for $username @ $domain."
#Testflag? 
$testFlag = $xml.Root.TestFlag

if ($testFlag -eq "true") {
    Write-Host "Test-Flag ist gesetzt. Das Skript wird im Test-Modus ausgeführt. Es werden keine tatsächlichen Aktionen ausgeführt."
}
# VPN-Verbindungen hinzufügen
Write-Host "🚀 VPNs hinzufügen..."
if ($xml.Root.VPNConnections.Connection.Count -gt 0){
    foreach ($vpn in $xml.Root.VPNConnections.Connection) {
        #Write-Host "VPN-Name: $($vpn.Name), IP: $($vpn.IP)"
        if ($testFlag -eq "true") {
            Write-Host "Test: Hinzufügen der VPN-Verbindung: $($vpn.Name) mit IP: $($vpn.IP)"
        }
        # 2Do: VPN
    }
}else{
    Write-Host "🚨 Warnung: Keine VPNs gefunden..."
}

# Netzwerkdrucker hinzufügen
Write-Host "🚀 Drucker hinzufügen..."
if ($xml.Root.NetworkPrinters.Printer.Count -gt 0) {
    foreach ($printer in $xml.Root.NetworkPrinters.Printer) {
        Write-Host "Drucker-Name: $($printer.Name), IP: $($printer.IP)"
        if ($testFlag -eq "true") {
            Write-Host "Test: Hinzufügen des Druckers: $($printer.Name) mit IP: $($printer.IP) am Standort: $($printer.Location)"
            Write-Host "Test: Test-Flag ist gesetzt. Das Skript wird im Test-Modus ausgeführt. Es werden keine tatsächlichen Aktionen ausgeführt."
            Write-Host "Test: Variablen für Drucker werden angezeigt:"
            Write-Host "Test: PrinterPortName: $($PrinterPortName)"
            Write-Host "Test: PrinterIPAddress: $($PrinterIPAddress)"
            Write-Host "Test: PrinterDriverName: $($PrinterDriverName)"
            Write-Host "Test: PrinterName: $($PrinterName)"
            Write-Host "Test: DriverPath: $($DriverPath)"
            Write-Host "Test: PrinterPortNumber: $($PrinterPortNumber)"
        } else {
            # Hier fügst du den tatsächlichen Code zum Hinzufügen des Druckers ein
            $PrinterPortName = $xml.NetworkPrinters.Printer.PortName
            $PrinterIPAddress = $xml.NetworkPrinters.Printer.IP
            $PrinterDriverName = $xml.NetworkPrinters.Printer.DriverName
            $PrinterName = $xml.NetworkPrinters.Printer.PrinterName
            $DriverPath = $xml.NetworkPrinters.Printer.DriverPath
            $PrinterPortNumber = $xml.NetworkPrinters.Printer.PortNumber

            $PrinterPort = [wmiclass]"Win32_TCPIPPrinterPort"
            $PrinterPort.Name = $PrinterPortName
            $PrinterPort.SNMPEnabled = $false
            $PrinterPort.Protocol = 1
            $PrinterPort.HostAddress = $PrinterIPAddress
            $PrinterPort.PortNumber = $PrinterPortNumber
            $PrinterPort.Put()

            $Driver = Get-WmiObject -Class Win32_PrinterDriver | Where-Object {$_.Name -like "$PrinterDriverName*"}

            if (-not $Driver) {
                $Driver = Get-WmiObject -Class Win32_PrinterDriver | Where-Object {$_.Name -like "$PrinterDriverName*"}
                $Driver = $Driver | Copy-Item -Destination $DriverPath
                $Driver = Get-Item -Path $DriverPath | Select-Object -ExpandProperty Name
            }

            $Printers = [wmiclass]"Win32_Printer"
            $Printers.DriverName = $Driver.Name
            $Printers.PortName = $PrinterPortName
            $Printers.DeviceID = $PrinterName
            $Printers.Put()

            Write-Host "Drucker wurde hinzugefügt."
        }
        
    }
}else{
    Write-Host "Warnung: Keine Drucker gefunden."
}

# Benutzer aus dem Active Directory ziehen und als lokalen Admin anlegen

#$securePassword = ConvertTo-SecureString "Passwort" -AsPlainText -Force
#New-LocalUser -Name $username -Password $securePassword -FullName $username -Description "Neuer lokaler Administrator"
#Add-LocalGroupMember -Group "Administratoren" -Member $username

# Weitere Aktionen für den Benutzer ausführen
# Füge hier weitere Aktionen hinzu, die du für den Benutzer ausführen möchtest

Write-Host "Das Skript wurde erfolgreich ausgeführt."