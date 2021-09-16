###############################
# Author: Carlos Vargas
# Name: setupmodules4azure.ps1
###############################

# configure Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Install NuGet
Install-Module PowershellGet -Force

#Install AZ Module
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
