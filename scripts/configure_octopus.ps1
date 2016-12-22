
$ConfScript = @"

function Invoke-InstallSQL{
`$output = "C:\SqlDownload\SQLEXPR_x64_ENU.exe"
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
`$InstallFlags = '/Q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="vagrant" /SQLSVCPASSWORD="vagrant" /SQLSYSADMINACCOUNTS="vagrant" /AGTSVCACCOUNT="NT AUTHORITY\System" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS'
Start-Process `$SQL -ArgumentList `$InstallFlags -wait -Verb RunAs 


`$time = Get-Date
write-output "Finished Installing SQL - `$Time" | Out-File -Append C:\logs.txt 

}


function Invoke-ConfigureOctopus{

[CmdletBinding()]
param (
[string]`$Exe
)

`$time = Get-Date
`$flags = 'create-instance --console --instance="OctopusServer" --config "C:\Octopus\OctopusServer.config"'

write-output "
================================

Create Octo Instance - `$Time
using: `$Exe
with flags: `$flags

================================
" | Out-File -Append C:\logs.txt 

Write-Output "Configuring Instance"


Start-Process `$Exe -ArgumentList `$flags -wait -nonewwindow -RedirectStandardOutput C:\ConfigureOcto.log

}

function Invoke-OctoDBConfig{
[CmdletBinding()]
param (
[string]`$Exe
)

`$time = Get-Date
write-output "
================================

Configuring DB/Base Settings - `$Time

================================
" | Out-File -Append C:\logs.txt 


`$ArgList = 'configure --console --instance "OctopusServer" --home "C:\Octopus" --storageConnectionString "Data Source=(local);Initial Catalog=Octo;Integrated Security=True;User ID=vagrant;Password=vagrant" --upgradeCheck "True" --upgradeCheckWithStatistics "True" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943"' + " --serverNodeName `$env:ComputerName"
Start-Process `$Exe -ArgumentList `$ArgList -wait -nonewwindow  -RedirectStandardOutput C:\OctoDB.log

}

function Invoke-OctoDBAuth{
[CmdletBinding()]
param (
[string]`$Exe
)
`$time = Get-Date
`$flags = 'database --console --instance "OctopusServer" --create --grant "NT AUTHORITY\SYSTEM"'
Write-output "
==================================

Configuring Auth on Octo for DB - `$Time
using: `$Exe
with flags: `$flags

==================================
"  | Out-File -Append C:\logs.txt 

Start-Process `$Exe -ArgumentList `$flags -wait -nonewwindow   -RedirectStandardOutput C:\OctoDBAuth.log

}

function Invoke-OctoService{
[CmdletBinding()]
param (
[string]`$Exe
)
`$time = Get-Date
`$flags = 'service --console --instance="OctopusServer" --stop'
Write-Output "
=================================

Creating Service - `$Time
using: `$Exe
with flags: `$flags

=================================
"| Out-File -Append C:\logs.txt 
Start-Process `$Exe -ArgumentList `$flags -wait -nonewwindow  -RedirectStandardOutput C:\OctoService.log

}

function Invoke-OctoAdmin {
[CmdletBinding()]
param (
[string]`$Exe
)
`$time = Get-Date
`$flags = 'admin --console --instance "OctopusServer" --username "admin" --email "admin@admin.com" --password "Vagrant!"'
Write-Output "
=================================

Creating Admin - `$Time
using: `$Exe
with flags: `$flags

=================================
" | Out-File -Append C:\logs.txt 
Start-Process `$Exe -argumentList `$flags -wait -nonewwindow   -RedirectStandardOutput C:\OctoAdmin.log

}

function Invoke-ApplyLicense {
[CmdletBinding()]
param (
[string]`$Exe
)
`$time = Get-Date
`$flags = 'license --console --instance="OctopusServer" --licenseBase64="PExpY2Vuc2UgU2lnbmF0dXJlPSJXUzg0ZXUzUzR6MWFXRm1nY3h2NUtNUHh3RHZhMkwvVWFOTC9PRWpQdHhiWDNGMzVWVmNEMDVKeGFRaXlUY09wbU1pNVJsRGYyV3dWY2hleElHUENqdz09Ij4NCiAgPExpY2Vuc2VkVG8+VGVzdDwvTGljZW5zZWRUbz4NCiAgPExpY2Vuc2VLZXk+NDkyOTUtMDQzMzctMjg0MjMtMjI1MTk8L0xpY2Vuc2VLZXk+DQogIDxWZXJzaW9uPjIuMDwhLS0gTGljZW5zZSBTY2hlbWEgVmVyc2lvbiAtLT48L1ZlcnNpb24+DQogIDxWYWxpZEZyb20+MjAxNi0xMi0wMjwvVmFsaWRGcm9tPg0KICA8VmFsaWRUbz4yMDE3LTAxLTE2PC9WYWxpZFRvPg0KICA8UHJvamVjdExpbWl0PlVubGltaXRlZDwvUHJvamVjdExpbWl0Pg0KICA8TWFjaGluZUxpbWl0PlVubGltaXRlZDwvTWFjaGluZUxpbWl0Pg0KICA8VXNlckxpbWl0PlVubGltaXRlZDwvVXNlckxpbWl0Pg0KPC9MaWNlbnNlPg==" --wait="5000"'
Write-Output "
==================================

Applying License - `$Time
using: `$Exe
with flags: `$flags

==================================
" | Out-File -Append C:\logs.txt
Start-Process `$Exe -ArgumentList `$flags -wait -nonewwindow  -RedirectStandardOutput C:\OctoLicense.log


}


function Invoke-RestartOctoService {
[CmdletBinding()]
param (
[string]`$Exe
)
`$time = Get-Date
`$flags = 'service --console --instance="OctopusServer" --install --reconfigure --start'
Write-Output "
==================================

Restarting service - `$Time
using: `$Exe
with flags: `$flags

==================================
" | Out-File -Append C:\logs.txt
Start-Process `$Exe -ArgumentList `$flags -wait -nonewwindow   -RedirectStandardOutput C:\OctoService.log

}


function Invoke-FinalizeOctoConfig {
[CmdletBinding()]
param (
[string]`$Exe
)
`$time = Get-Date
write-output "
===============================================

Finished Configuring Octo Instance - `$Time

================================================
" | Out-File -Append C:\logs.txt 

`$time = Get-Date
write-output "Adding Firewall Exception - `$Time" | Out-File -Append C:\logs.txt 
Write-Output "Adding Firewall Exception"
netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=80

`$time = Get-Date
write-output "Finished Adding Firewall Exception - `$Time" | Out-File -Append C:\logs.txt 
}


`$Exe = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" 

Invoke-InstallSQL

Invoke-ConfigureOctopus -Exe `$Exe

Invoke-OctoDBConfig -Exe `$Exe

Invoke-OctoDBAuth -Exe `$Exe

Invoke-OctoService -Exe `$Exe

Invoke-OctoAdmin -Exe `$Exe

Invoke-ApplyLicense -Exe `$Exe

Invoke-RestartOctoService -Exe `$Exe

Invoke-FinalizeOctoConfig -Exe `$Exe

`$time = Get-Date
write-output "Job Completed - `$Time" | Out-File -Append C:\logs.txt 
"@

<#
function Invoke-DownloadSQL{
Write-Output "Downloading SQL"

New-item C:\SqlDownload -ItemType Directory -Force
New-item C:\logs.txt 

$time = Get-Date
write-output "Starting SQL Download - `$Time" | Out-File -Append C:\logs.txt 
$url = "https://download.microsoft.com/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/Express%2064BIT/SQLEXPR_x64_ENU.exe"
$output = "C:\SqlDownload\SQLEXPR_x64_ENU.exe"

(New-Object System.Net.WebClient).DownloadFile($url, $output)



}
#>

function Invoke-DownloadSQL($url, $targetFile)
{
   $uri = New-Object "System.Uri" "$url"
   $request = [System.Net.HttpWebRequest]::Create($uri)
   $request.set_Timeout(15000) #15 second timeout
   $response = $request.GetResponse()
   $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
   $responseStream = $response.GetResponseStream()
   $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
   $buffer = new-object byte[] 10KB
   $count = $responseStream.Read($buffer,0,$buffer.length)
   $downloadedBytes = $count
   while ($count -gt 0)
   {
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
   }
   Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"
   $targetStream.Flush()
   $targetStream.Close()
   $targetStream.Dispose()
   $responseStream.Dispose()
}


New-item C:\logs.txt 
New-item C:\SqlDownload -ItemType Directory -Force

Invoke-DownloadSQL -url "https://download.microsoft.com/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/Express%2064BIT/SQLEXPR_x64_ENU.exe" -targetFile "C:\SqlDownload\SQLEXPR_x64_ENU.exe"

New-Item C:\Scripts\Configure_octopus.ps1 -type file -force -value $ConfScript


$secpasswd = ConvertTo-SecureString vagrant -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("Administrator", $secpasswd)

Register-ScheduledJob -Name "InstallOcto" -FilePath "C:\Scripts\Configure_octopus.ps1" -Credential $credential -MaxResultcount 30 -ScheduledJobOption (New-ScheduledJobOption -RunElevated) -Trigger (New-JobTrigger -AtStartup)