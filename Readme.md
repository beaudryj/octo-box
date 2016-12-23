
Version 2.1.0

Date: 12/23/2016

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

# Credentials - 
    Box: 
        Administrator - vagrant 
        Vagrant - vagrant 
    Octopus Deploy: 
        Admin - Vagrant! 

# Currently in order to get SQL installed, the Instance has a startup script that runs on power on to install SQL and then configures octopus. Once the machine is up it takes roughly (Depending on network speed) 5-15Minutes for the instance to come up
