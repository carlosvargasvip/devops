####################################
# Author: Carlos Vargas
# Name: setupmodules4sftp.ps1
####################################

############
# Configure Modules Script

# configure Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Install NuGet
Install-Module PowershellGet -Force

#Install Posh-ssh
Install-Module posh-ssh -Force
