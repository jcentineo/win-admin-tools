###################################################################
#Created Oct 13 2022
#
#This script will query AD for a list of users with "Created Date" value
#within the last 7 days. This report configured on a Scheduled Task can help
#to keep tabs on new accounts created in your AD, and spot any suspicious 
#accounts. 
####################################################################

#Replace Variables as needed for your environment
$smtpServer="smtp.relay.url.com"
$from = "FROM <FROM@Domain.com>"
$adminEmailAddr = "To@Domain.com" #multiple addr allowed but MUST be independent strings separated by comma
$logFile = "C:\Scripts\AD New Users\NewUsers-7Days.txt" 
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format MM-dd-yyyy
$SearchDate = (Get-Date).AddDays(-7).Date

Get-ADUser -Filter { WhenCreated -ge $SearchDate } `
  -Properties WhenCreated,EmailAddress,LastLogonDate |
  Select-Object WhenCreated,SamAccountName, EmailAddress, LastLogonDate |
Out-File -FilePath "C:\Scripts\AD New Users\NewUsers-7Days.txt"

$Results = Get-Content "C:\Scripts\AD New Users\NewUsers-7Days.txt"

 $body="
    <h1>Active Directory New Users Report</h1>
    <h2><b>Report Date:</b> $date<br></h2><br>
	Please check the attached report. If any accounts appear suspicious, please investigate.
    "

Send-Mailmessage -smtpServer $smtpServer -from $from -to $adminEmailAddr -subject "Active Directory New User Report" -body $body -bodyasHTML -Attachments "$logFile" -priority High -Encoding $textEncoding -ErrorAction Stop -ErrorVariable err

Remove-Item "$logFile"