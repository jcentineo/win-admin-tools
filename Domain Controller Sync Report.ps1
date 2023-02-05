###################################################################
#Created Oct 12 2022
#
#Create a Scheduled Task on a domain controller or another VM that has AD Tools installed
#This report will query the DC's and provide a sync report. 
#If any DC shows a sync delay significantly different than other DC's, investigate further. 
###################################################################

#Replace variables as needed
$smtpServer="mail.relay.url.com"
$from = "NAME <NAME@domain.com>"
$adminEmailAddr = "FROM@domain.com" #multiple addr allowed but MUST be independent strings separated by comma
$logFile = "C:\Scripts\AD Sync Status\ADSyncStatus.txt" 
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format MM-dd-yyyy


repadmin /replsummary | Out-File -FilePath 'C:\Scripts\AD Sync Status\ADSyncStatus.txt'

 $body="
    <h1>Active Directory Weekly Sync Report</h1>
    <h2><b>Report Date:</b> $date<br></h2><br>
	Please check the attached report. If any of the DC's show a delay of more than 48 hours please investigate.<br>
    "

Send-Mailmessage -smtpServer $smtpServer -from $from -to $adminEmailAddr -subject "Active Directory Weekly Sync Report" -body $body -bodyasHTML -Attachments "$logFile" -priority High -Encoding $textEncoding -ErrorAction Stop -ErrorVariable err

Remove-Item "$logFile"