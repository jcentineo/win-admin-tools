###################################################################
#PowerShell script to automate this task to change the all Office 365 user accounts with user@domain.onmicrosoft.com. to user@domain.com
#Be Sure to Install Azure AD modules from Azure
#Replace "BrokenDomain0.onmicrosoft.com" with the broken domain you're trying to fix
#Replace "NewDomain.com" with your actual domain
###################################################################

Connect-MsolService #-Credential $cred
 
Get-MsolUser -All | Where { $_.UserPrincipalName.ToLower().EndsWith("BrokenDomain0.onmicrosoft.com") } | Select-Object UserPrincipalName, Title, DisplayName, IsLicensed | export-csv –path C:\Temp\MSOL_Users_BeforeUpdate.csv
 
Get-MsolUser -All |
 Where { $_.UserPrincipalName.ToLower().EndsWith("BrokenDomain0.onmicrosoft.com") } |
 ForEach {
 #if($count -eq 1) #For Testing the first result
 # {
 $upnVal = $_.UserPrincipalName.Split("@")[0] + "@NewDomain.com"
 Write-Host "Changing UPN value from: "$_.UserPrincipalName" to: " $upnVal -ForegroundColor Magenta
 Set-MsolUserPrincipalName -ObjectId $_.ObjectId -NewUserPrincipalName ($upnVal)
 $count++
 # }
 }
 
Get-MsolUser -All | Select-Object UserPrincipalName, Title, DisplayName,IsLicensed | export-csv –path C:\Temp\MSOL_Users_AfterUpdate.csv