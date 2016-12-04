Function Invoke-SQLInstall {
Write-Output "Downloading SQL"
$url = "https://download.microsoft.com/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/Express%2064BIT/SQLEXPR_x64_ENU.exe"
$output = "$PSScriptRoot\SQLEXPR_x64_ENU.exe"

(New-Object System.Net.WebClient).DownloadFile($url, $output)

Write-Output "Extracting SQL Setup"
start-process $output "/q /x:$PSScriptRoot\SqlExpr" -wait -verb RunAs

Write-Output "Installing SQL"
& "$PSScriptRoot\SqlExpr\Setup.exe" /Q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="vagrant" /SQLSVCPASSWORD="vagrant" /SQLSYSADMINACCOUNTS="vagrant" /AGTSVCACCOUNT="NT AUTHORITY\System" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS 

Write-Output "Creating DB for Octopus"
$SQL = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\tools\Binn\SQLCMD.exe"

Start-Process $SQL '-Q "CREATE DATABASE Octo;"'

}


Function Invoke-OctoServer {
choco install octopusdeploy --confirm


$Exe = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" 

Write-Output "Configuring Instance"
Start-Process $Exe 'create-instance --instance="OctopusServer" --config "C:\Octopus\OctopusServer.config"' -Wait -Verb RunAs
Write-Output "Configuring DB/Base Settings"
Start-Process $Exe "configure --instance `"OctopusServer`" --home `"C:\Octopus`" --storageConnectionString `"Data Source=(local);Initial Catalog=Octo;Integrated Security=True;User ID=vagrant;Password=vagrant`" --upgradeCheck `"True`" --upgradeCheckWithStatistics `"True`" --webAuthenticationMode `"UsernamePassword`" --webForceSSL `"False`" --webListenPrefixes `"http://localhost:80/`" --commsListenPort `"10943`" --serverNodeName `"$env:ComputerName`"" -Wait -Verb RunAs
Start-Process $Exe 'database --instance "OctopusServer" --create --grant "NT AUTHORITY\SYSTEM"' -Wait -Verb RunAs
Write-Output "Creating Service"
Start-Process $Exe 'service --instance="OctopusServer" --stop' -Wait -Verb RunAs
Write-Output "Creating Admin"
Start-Process $Exe 'admin --instance "OctopusServer" --username "admin" --email "admin@admin.com" --password "Vagrant!"' -Wait -Verb RunAs
Write-Output "Applying License"
Start-Process $Exe 'license --instance="OctopusServer" --licenseBase64="PExpY2Vuc2UgU2lnbmF0dXJlPSJXUzg0ZXUzUzR6MWFXRm1nY3h2NUtNUHh3RHZhMkwvVWFOTC9PRWpQdHhiWDNGMzVWVmNEMDVKeGFRaXlUY09wbU1pNVJsRGYyV3dWY2hleElHUENqdz09Ij4NCiAgPExpY2Vuc2VkVG8+VGVzdDwvTGljZW5zZWRUbz4NCiAgPExpY2Vuc2VLZXk+NDkyOTUtMDQzMzctMjg0MjMtMjI1MTk8L0xpY2Vuc2VLZXk+DQogIDxWZXJzaW9uPjIuMDwhLS0gTGljZW5zZSBTY2hlbWEgVmVyc2lvbiAtLT48L1ZlcnNpb24+DQogIDxWYWxpZEZyb20+MjAxNi0xMi0wMjwvVmFsaWRGcm9tPg0KICA8VmFsaWRUbz4yMDE3LTAxLTE2PC9WYWxpZFRvPg0KICA8UHJvamVjdExpbWl0PlVubGltaXRlZDwvUHJvamVjdExpbWl0Pg0KICA8TWFjaGluZUxpbWl0PlVubGltaXRlZDwvTWFjaGluZUxpbWl0Pg0KICA8VXNlckxpbWl0PlVubGltaXRlZDwvVXNlckxpbWl0Pg0KPC9MaWNlbnNlPg==" --wait="5000"' -Wait -Verb RunAs
Write-Output "Restarting service"
Start-Process $Exe 'service --instance="OctopusServer" --install --reconfigure --start' -Wait -Verb RunAs

Write-Output "Adding Firewall Exception"
netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=80

}

Invoke-SQLInstall

Invoke-OctoServer