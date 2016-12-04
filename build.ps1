[cmdletbinding()]
param(
    [switch]$Force,
    [switch]$SkipAtlas,
    [switch]$SkipVboxTools
)


$osData = @{
    os_name = 'win2012r2core' 
    guest_os_type = 'Windows2012_64'
    full_os_name = 'Windows2012R2Core'
    iso_checksum = '849734f37346385dac2c101e4aacba4626bb141c'
    iso_url = 'http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO'
}

if($SkipVboxTools)
{
    $osData.VboxCmd = "false"
}
else
{
    $osData.VboxCmd = "true"
}

if ($Force)
{
    $osData.ForceCmd = '-force'
}
else
{
    $osData.ForceCmd = ''
}

Write-Output $osData | ConvertTo-Json

# Base Image and VirtualBox if enabled
Start-Process -FilePath 'packer.exe' -ArgumentList "build $($osData.ForceCmd) -var `"install_vbox_tools=$($osData.VboxCmd)`" -var `"os_name=$($osData.os_name)`" -var `"iso_checksum=$($osData.iso_checksum)`" -var `"iso_url=$($osData.iso_url)`" -var `"guest_os_type=$($osData.guest_os_type)`" .\01-windows-base.json" -Wait -NoNewWindow

# Installs Windows Updates and WMF5
Start-Process -FilePath 'packer.exe' -ArgumentList "build $($osData.ForceCmd) -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-base\$($osData.os_name)-base.ovf`" .\02-win_updates-wmf5.json" -Wait -NoNewWindow

# Install Octopus Deploy
Start-Process -FilePath 'packer.exe' -ArgumentList "build $($osData.ForceCmd) -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-updates_wmf5\$($osData.os_name)-updates_wmf5.ovf`" .\03-install_octopus.json" -Wait -NoNewWindow


# Cleanup
Start-Process -FilePath 'packer.exe' -ArgumentList "build $($osData.ForceCmd) -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-octopus\$($osData.os_name)-octopus.ovf`" .\04-cleanup.json" -Wait -NoNewWindow

if ($SkipAtlas)
{
    # Vagrant Image Only
    Start-Process -FilePath 'packer.exe' -ArgumentList "build $($osData.ForceCmd) -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-cleanup\$($osData.os_name)-cleanup.ovf`" .\05-local.json" -Wait -NoNewWindow
}
else
{
    # Vagrant + Atlas
    Start-Process -FilePath 'packer.exe' -ArgumentList "build $($osData.ForceCmd) -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-cleanup\$($osData.os_name)-cleanup.ovf`" -var `"full_os_name=$($osData.full_os_name)`" .\05-atlas.json" -Wait -NoNewWindow
}

