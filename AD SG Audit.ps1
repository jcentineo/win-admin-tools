###################################################################
#Security Group Audit Script
#
#This will run through a list of specified groups and output all
#members to CSV
###################################################################

Import-Module ActiveDirectory

#Replace Group1, Group2 with the names of the AD groups you need to audit
$Groups = ("Group1", "Group2")
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

$Table | export-csv "C:\Temp\AD_Group_Audit.csv" -NoTypeInformation