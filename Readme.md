# Octo Box

Version 1.1.0

Date: 12/4/2016

## Packer build for Octo Box 

This Repository is used for generating an Octopus Deploy Server image using packer. 
The scripts here will 
    - build download Windows Server 2012 Core 
    - install 
        virtualbox tools
        windows updates
        chocolatey
        Powershell WMF5
        SQL Express 2014 
        Octopus Deploy Server
    - Create a Octo DB on the SQL Server
    - Configure Octopus Deploy with trial license, and attach to the DB
    - Configure Firewall to allow inbound on port 80

