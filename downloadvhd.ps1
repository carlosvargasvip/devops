###################################
# Name: DownloadVHDFromSFTP.ps1
# Author: Carlos Vargas
# Version: 1.0
# Note: This will allow you to download a VHD from the sftp server
###################################

param( 

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The Download Location For The VHD. Ex. d:\folder1\file.vhd")]

[string]$downloadlocation,

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The SFTPServer. Ex. sftp.domain.com")]

[string]$sftpserver,

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The SFTP Username. Ex. username")]

[string]$sftpusername,

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The SFTP Password. Ex. password")]

[string]$sftppass

)


######################################
# Convert Plain Text to SecureString #
######################################
$sftpsecurepass = ConvertTo-SecureString $sftppass -AsPlainText -Force

############################
# Create credential object #
############################
$creds = New-Object System.Management.Automation.PSCredential ($sftpusername, $sftpsecurepass)


#################
# Make Connection to SFTP Server
$sftpsession = New-SFTPSession -ComputerName $sftpserver -Credential $creds 

########
#List Directory and get vhd details from cloud

$sftpservercontent = Get-SFTPChildItem -SessionId 0 -Recursive -Path "/" 
$vhdrestoredetails = $sftpservercontent | ? {$_.name -like "*.vhd"}
Clear
Write-Host "Download VHD Process Starting..." 
$vhdrestorefilepath = $vhdrestoredetails.FullName
Write-host "SFTP Location for VHD File:" $vhdrestorefilepath
$vhdrestorefilename = $vhdrestoredetails.name
Write-host "VHD File name:" $vhdrestorefilename


################
# Download VHD file to localfolder

Get-SFTPItem -Session 0 -Path $vhdrestorefilepath -Destination $downloadlocation -Verbose
