###################################################
# Name: uploadvhd2azure.ps1                       #
# Author: Carlos Vargas                           #
# Version: 1.0                                    #
# Notes: This script will upload a vhd file as    #
# a managed disk to your azure subscription       #
###################################################


#######################################
# Command Pipeline Values to speed up #
#######################################

param( 

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The VHD File Full Path. Ex. d:\folder1\file.vhd")]

[string]$vhdfilelocationpath,

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The Azure VM Type. Ex. 1 or 2")]

[string]$VMGen,

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The Azure Region. Ex. eastus")]

[string]$azregion,

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The Azure Resource Group. Ex. demo-rg")]

[string]$azresourcegroup,

[Parameter( Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="InputVariables",
            HelpMessage="You Need To Provide The Upload VHD File. Max 15 characters Ex. restoredisk1")]

[string]$uploaddiskname


)

Write-Host "Your VHD File Location: " $vhdfilelocationpath
Write-Host "Your Azure Region is: " $azregion
Write-Host "Your Azure Resource Group: " $azresourcegroup
Write-Host "Your VHD Upload File Name is: " $uploaddiskname


#####################################
# Set Powershell in TLS 1.2 version #
#####################################
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


###############################################
# Azcopy                                      #
# Test if AzCopy.exe exists in current folder #
###############################################
$WantFile = "azcopy.exe"
$AzCopyExists = Test-Path $WantFile
Write-Host "AzCopy exists:" $AzCopyExists

# Download AzCopy if it doesn't exist
If ($AzCopyExists -eq $False)
{
    Write-Host "AzCopy not found. Downloading..."
    
    #Download AzCopy
    Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing
 
    #Expand Archive
    write-host "Expanding archive..."
    Expand-Archive ./AzCopy.zip ./AzCopy -Force

    # Copy AzCopy to current dir
    Get-ChildItem ./AzCopy/*/azcopy.exe | Copy-Item -Destination "./AzCopy.exe"
}
else
{
    Write-Host "AzCopy found, skipping download."
}

##########################
# Define AZcopy variable #
##########################
$azcopyfile = ".\azcopy.exe"


####################
# Connect to Azure #
####################
$AzureConnection = Connect-AzAccount 


#########################
# Define VHD Parameters #
#########################
$vhdfile = $vhdfilelocationpath

$vhdSizeBytes = (Get-Item $vhdfile).length

####################################
# Azure Managed Disk Configuration #
####################################
$diskconfig = New-AzDiskConfig -SkuName 'Premium_LRS' -HyperVGeneration "V$VMGen" -OsType 'Windows' -UploadSizeInBytes $vhdSizeBytes -Location $azregion -CreateOption 'Upload' 

$azdiskconfig = New-AzDisk -ResourceGroupName $azresourcegroup -DiskName $uploaddiskname -Disk $diskconfig

#########################
# Get Disk Write Access #
#########################
$diskSas = Grant-AzDiskAccess -ResourceGroupName $azresourcegroup -DiskName $uploaddiskname -DurationInSecond 86400 -Access 'Write'

$disk = Get-AzDisk -ResourceGroupName $azresourcegroup -DiskName $uploaddiskname

##########################
# Upload VHD with Azcopy #
##########################
.\azcopy.exe copy $vhdfilelocationpath $diskSas.AccessSAS --blob-type PageBlob


###############################
# Remove Write Access To Disk #
###############################
Revoke-AzDiskAccess -ResourceGroupName $azresourcegroup -DiskName $uploaddiskname
