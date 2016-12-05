$ConfScript = @"


function Invoke-InstallSQL{
Write-Output "Downloading SQL"

New-item C:\SqlDownload -ItemType Directory -Force
New-item C:\logs.txt 

`$time = Get-Date
write-output "Starting SQL Download - `$Time" | Out-File -Append C:\logs.txt 
`$url = "https://download.microsoft.com/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/Express%2064BIT/SQLEXPR_x64_ENU.exe"
`$output = "C:\SqlDownload\SQLEXPR_x64_ENU.exe"

write-output `$url
write-output `$output

(New-Object System.Net.WebClient).DownloadFile(`$url, `$output)

`$time = Get-Date
write-output "Finished SQL Download - `$Time" | Out-File -Append C:\logs.txt 

`$time = Get-Date
write-output "Extracting SQL Download - `$Time" | Out-File -Append C:\logs.txt 
Write-Output "Extracting SQL Setup"
start-process `$output "/q /x:C:\SQL\SqlExpr" -wait -verb RunAs

`$time = Get-Date
write-output "Finished Extracting SQL Download- `$Time" | Out-File -Append C:\logs.txt 

`$SQL =  "C:\SQL\SqlExpr\SETUP.EXE"
`$time = Get-Date
write-output "Installing SQL - `$Time" | Out-File -Append C:\logs.txt 
Write-Output "Installing SQL"
`$InstallFlags = '/Q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT=`"vagrant`" /SQLSVCPASSWORD=`"vagrant`" /SQLSYSADMINACCOUNTS`="vagrant" /AGTSVCACCOUNT=`"NT AUTHORITY\System`" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS'
Start-Process `$SQL -ArgumentList `$InstallFlags -wait -Verb RunAs | Out-File -Append C:\Logs.txt


`$time = Get-Date
write-output "Finished Installing SQL - `$Time" | Out-File -Append C:\logs.txt 

}


function Invoke-ConfigureOctopus{
`$Exe = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" 

`$time = Get-Date
write-output "Configuring OctoInstance - `$Time" | Out-File -Append C:\logs.txt 
 

Write-Output "Configuring Instance"
Start-Process `$Exe 'create-instance --instance="OctopusServer" --config "C:\Octopus\OctopusServer.config"' -NoNewWindow -Wait | Out-File -Append C:\Logs.txt
Write-Output "Configuring DB/Base Settings"

`$ArgList = 'configure --instance "OctopusServer" --home "C:\Octopus" --storageConnectionString "Data Source=(local);Initial Catalog=Octo;Integrated Security=True;User ID=vagrant;Password=vagrant" --upgradeCheck "True" --upgradeCheckWithStatistics "True" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943"' + " --serverNodeName `$env:ComputerName"
Start-Process `$Exe -ArgumentList `$ArgList -NoNewWindow -Wait | Out-File -Append C:\Logs.txt

Start-Process `$Exe 'database --instance "OctopusServer" --create --grant "NT AUTHORITY\SYSTEM"' -NoNewWindow -Wait | Out-File -Append C:\Logs.txt
Write-Output "Creating Service"
Start-Process `$Exe 'service --instance="OctopusServer" --stop' -NoNewWindow -Wait | Out-File -Append C:\Logs.txt
Write-Output "Creating Admin"
Start-Process `$Exe 'admin --instance "OctopusServer" --username "admin" --email "admin@admin.com" --password "Vagrant!"' -NoNewWindow -Wait | Out-File -Append C:\Logs.txt
Write-Output "Applying License"
Start-Process `$Exe 'license --instance="OctopusServer" --licenseBase64="PExpY2Vuc2UgU2lnbmF0dXJlPSJXUzg0ZXUzUzR6MWFXRm1nY3h2NUtNUHh3RHZhMkwvVWFOTC9PRWpQdHhiWDNGMzVWVmNEMDVKeGFRaXlUY09wbU1pNVJsRGYyV3dWY2hleElHUENqdz09Ij4NCiAgPExpY2Vuc2VkVG8+VGVzdDwvTGljZW5zZWRUbz4NCiAgPExpY2Vuc2VLZXk+NDkyOTUtMDQzMzctMjg0MjMtMjI1MTk8L0xpY2Vuc2VLZXk+DQogIDxWZXJzaW9uPjIuMDwhLS0gTGljZW5zZSBTY2hlbWEgVmVyc2lvbiAtLT48L1ZlcnNpb24+DQogIDxWYWxpZEZyb20+MjAxNi0xMi0wMjwvVmFsaWRGcm9tPg0KICA8VmFsaWRUbz4yMDE3LTAxLTE2PC9WYWxpZFRvPg0KICA8UHJvamVjdExpbWl0PlVubGltaXRlZDwvUHJvamVjdExpbWl0Pg0KICA8TWFjaGluZUxpbWl0PlVubGltaXRlZDwvTWFjaGluZUxpbWl0Pg0KICA8VXNlckxpbWl0PlVubGltaXRlZDwvVXNlckxpbWl0Pg0KPC9MaWNlbnNlPg==" --wait="5000"' -Wait -Verb RunAs
Write-Output "Restarting service"
Start-Process `$Exe 'service --instance="OctopusServer" --install --reconfigure --start' -NoNewWindow -Wait | Out-File -Append C:\Logs.txt

`$time = Get-Date
write-output "Finished Configuring Octo Instance - `$Time" | Out-File -Append C:\logs.txt 

`$time = Get-Date
write-output "Adding Firewall Exception - `$Time" | Out-File -Append C:\logs.txt 
Write-Output "Adding Firewall Exception"
netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=80

`$time = Get-Date
write-output "Finished Adding Firewall Exception - `$Time" | Out-File -Append C:\logs.txt 
}

Invoke-InstallSQL

Invoke-ConfigureOctopus


`$time = Get-Date
write-output "Job Completed - `$Time" | Out-File -Append C:\logs.txt 
"@

New-Item C:\Scripts\Configure_octopus.ps1 -type file -force -value $ConfScript


$secpasswd = ConvertTo-SecureString vagrant -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("Administrator", $secpasswd)

Register-ScheduledJob -Name "InstallOcto" -FilePath "C:\Scripts\Configure_octopus.ps1" -Credential $credential -MaxResultcount 30 -ScheduledJobOption (New-ScheduledJobOption -RunElevated) -Trigger (New-JobTrigger -AtStartup)
