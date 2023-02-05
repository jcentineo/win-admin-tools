###################################################################
#Distribution List Audit Script
#
#This will run through a list of specified Distribution Lists and 
#output all members to CSV
###################################################################

Import-Module ActiveDirectory
#Replace values with the name of the groups you want to query
$Groups = ("Group1","Group2","Group3","Group4","Group5")

$Table = @()

$Record = [ordered]@{
"Group Name" = ""
"Name" = ""
"Username" = ""
}



Foreach ($Group in $Groups)
{
$Arrayofmembers = Get-ADGroupMember -identity $Group | select name,samaccountname | Sort-Object Name

foreach ($Member in $Arrayofmembers)
{
$Record."Group Name" = $Group
$Record."Name" = $Member.name
$Record."UserName" = $Member.samaccountname
$objRecord = New-Object PSObject -property $Record
$Table += $objrecord

}

}

$Table | export-csv "C:\Temp\Dist_List_Audit.csv" -NoTypeInformation