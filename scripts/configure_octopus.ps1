$ConfScript = @"

function Invoke-InstallSQL{
Write-Output "Installing SQL"
& "C:\SqlExpr\Setup.exe" /Q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="vagrant" /SQLSVCPASSWORD="vagrant" /SQLSYSADMINACCOUNTS="vagrant" /AGTSVCACCOUNT="NT AUTHORITY\System" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS 

Remove-Item "C:\SqlExpr" -Force
}

function Invoke-ConfigureOctopus{
`$Exe = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" 

Write-Output "Configuring Instance"
Start-Process `$Exe 'create-instance --instance="OctopusServer" --config "C:\Octopus\OctopusServer.config"' -Wait -Verb RunAs
Write-Output "Configuring DB/Base Settings"
Start-Process `$Exe "configure --instance `"OctopusServer`" --home `"C:\Octopus`" --storageConnectionString `"Data Source=(local);Initial Catalog=Octo;Integrated Security=True;User ID=vagrant;Password=vagrant`" --upgradeCheck `"True`" --upgradeCheckWithStatistics `"True`" --webAuthenticationMode `"UsernamePassword`" --webForceSSL `"False`" --webListenPrefixes `"http://localhost:80/`" --commsListenPort `"10943`" --serverNodeName `"`$env:ComputerName`"" -Wait -Verb RunAs
Start-Process `$Exe 'database --instance "OctopusServer" --create --grant "NT AUTHORITY\SYSTEM"' -Wait -Verb RunAs
Write-Output "Creating Service"
Start-Process `$Exe 'service --instance="OctopusServer" --stop' -Wait -Verb RunAs
Write-Output "Creating Admin"
Start-Process `$Exe 'admin --instance "OctopusServer" --username "admin" --email "admin@admin.com" --password "Vagrant!"' -Wait -Verb RunAs
Write-Output "Applying License"
Start-Process `$Exe 'license --instance="OctopusServer" --licenseBase64="PExpY2Vuc2UgU2lnbmF0dXJlPSJXUzg0ZXUzUzR6MWFXRm1nY3h2NUtNUHh3RHZhMkwvVWFOTC9PRWpQdHhiWDNGMzVWVmNEMDVKeGFRaXlUY09wbU1pNVJsRGYyV3dWY2hleElHUENqdz09Ij4NCiAgPExpY2Vuc2VkVG8+VGVzdDwvTGljZW5zZWRUbz4NCiAgPExpY2Vuc2VLZXk+NDkyOTUtMDQzMzctMjg0MjMtMjI1MTk8L0xpY2Vuc2VLZXk+DQogIDxWZXJzaW9uPjIuMDwhLS0gTGljZW5zZSBTY2hlbWEgVmVyc2lvbiAtLT48L1ZlcnNpb24+DQogIDxWYWxpZEZyb20+MjAxNi0xMi0wMjwvVmFsaWRGcm9tPg0KICA8VmFsaWRUbz4yMDE3LTAxLTE2PC9WYWxpZFRvPg0KICA8UHJvamVjdExpbWl0PlVubGltaXRlZDwvUHJvamVjdExpbWl0Pg0KICA8TWFjaGluZUxpbWl0PlVubGltaXRlZDwvTWFjaGluZUxpbWl0Pg0KICA8VXNlckxpbWl0PlVubGltaXRlZDwvVXNlckxpbWl0Pg0KPC9MaWNlbnNlPg==" --wait="5000"' -Wait -Verb RunAs
Write-Output "Restarting service"
Start-Process `$Exe 'service --instance="OctopusServer" --install --reconfigure --start' -Wait -Verb RunAs

Write-Output "Adding Firewall Exception"
netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=80
}

Invoke-InstallSQL

Invoke-ConfigureOctopus

"@

New-Item C:\Scripts\Configure_octopus.ps1 -type file -force -value $ConfScript


$secpasswd = ConvertTo-SecureString vagrant -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("Administrator", $secpasswd)

Register-ScheduledJob -Name "InstallOcto" -FilePath "C:\Scripts\Configure_octopus.ps1" -Credential $credential -MaxResultcount 30 -ScheduledJobOption (New-ScheduledJobOption -DoNotAllowDemandStart) -Trigger (New-JobTrigger -AtStartup)
