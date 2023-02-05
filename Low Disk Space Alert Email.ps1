###################################################################
#Change variables as needed for from\to address an SMTP server
#Create Scheduled Task that monitors for event ID 2013. When triggered, have it run this script. 
###################################################################

#Variables
$From = "FromAddress@domain.com"
$Address1 = "ToAddress1@domain.com"
$Address2 = "ToAddress2@domain.com"
$Subject = "Low Disk Space Detected on Domain Controller"

$Body = 
"
Alert: Less than 10% disk space remaining.

Domain Controller: $env:computername

Please investigate immediately and take remedial action.
"

$SMTPServer = "email.relay.url.com"
$SMTPPort = "25"

Send-MailMessage -From $From -to $Address1, $Address2 -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl