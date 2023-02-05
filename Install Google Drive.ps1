###################################################################
#Created Nov 2022
#
#This script will install the latest Google Drive version, and set the default
#mount point based upon your preferred drive letter. 
#
###################################################################


#Set variable for installer folder path
$InstallerFolder="C:\Temp\"

#Test to see if path exists, if not, create folder. 
IF(!(Test-Path $InstallerFolder))
{
mkdir C:\Temp\}

#Download the latest Google Drive Desktop installer
wget https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe -outfile C:\Temp\GoogleDriveSetup.exe

#Change directories
cd 	C:\Temp\

#Perform installation
.\GoogleDriveSetup.exe --silent --gsuite_shortcuts=false

#Add the Default Mount Point registry entry
$registryPath = "HKLM:\Software\Google\DriveFS"
$Name = "DefaultMountPoint"
$value = "G:"
IF(!(Test-Path $registryPath))
  {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType String -Force | Out-Null}
 ELSE {
     New-ItemProperty -Path $registryPath -Name $name -Value $value `
     -PropertyType String -Force | Out-Null}

#Pause timer to wait for Drive to finish any background processing, otherwise installer delete will fail. 
Start-Sleep -Seconds 20

#Perform cleanup of the setup file
Remove-Item C:\Temp\GoogleDriveSetup.exe

exit 0