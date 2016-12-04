Function Invoke-SQLInstall {
Write-Output "Downloading SQL"
$url = "https://download.microsoft.com/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/Express%2064BIT/SQLEXPR_x64_ENU.exe"
$output = "$PSScriptRoot\SQLEXPR_x64_ENU.exe"

(New-Object System.Net.WebClient).DownloadFile($url, $output)

Write-Output "Extracting SQL Setup"
start-process $output "/q /x:$PSScriptRoot\SqlExpr" -wait -verb RunAs

Write-Output "Installing SQL"
& "$PSScriptRoot\SqlExpr\Setup.exe" /Q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="vagrant" /SQLSVCPASSWORD="vagrant" /SQLSYSADMINACCOUNTS="vagrant" /AGTSVCACCOUNT="NT AUTHORITY\System" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS 



}


Function Invoke-OctoServerInstall {
choco install octopusdeploy --confirm

}

Invoke-SQLInstall

Invoke-OctoServerInstall
