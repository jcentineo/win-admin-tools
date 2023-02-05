#################################################################################################################
#
# Password-Expiration-Notifications v20210428
# Highly Modified fork. https://gist.github.com/meoso/3488ef8e9c77d2beccfd921f991faa64
#
# Originally from v1.4 @ https://gallery.technet.microsoft.com/Password-Expiry-Email-177c3e27
# Robert Pearman (WSSMB MVP)
# TitleRequired.com
# Script to Automated Email Reminders when Users Passwords due to Expire.
#
# Requires: Windows PowerShell Module for Active Directory
#
# This script I take no credit for, all goes to the author above. 
#
##################################################################################################################
# Please Configure the following variables....
$testing = $false # Set to $false to Email Users. $true to email samples to administrators only (see $sampleEmails below)
$SearchBase="Enter the search base path for AD here" 
### PURGING this option; seems to cause issue. # $ExcludeList="'New Employees'|'Separated Employees'"   #in the form of "SubOU1|SubOU2|SubOU3" -- possibly needing single quote for OU's with spaces, separate OU's with pipe and double-quote the list.
$smtpServer="smpt.relay.url.com"
$expireindays = 14 #number of days of soon-to-expire paswords. i.e. notify for expiring in X days (and every day until $negativedays)
$negativedays = -120 #negative number of days (days already-expired). i.e. notify for expired X days ago
$from = "FROM <FROM@Domain.com>"
$logging = $true # Set to $false to Disable Logging
$logNonExpiring = $false
$logFile = "C:\Scripts\Password Expiry Report\PS-pwd-expiry.csv" # ie. c:\mylog.csv
$adminEmailAddr = "TO@Domain.com" #multiple addr allowed but MUST be independent strings separated by comma
$sampleEmails = 1 #number of sample email to send to adminEmailAddr when testing ; in the form $sampleEmails="ALL" or $sampleEmails=[0..X] e.g. $sampleEmails=0 or $sampleEmails=3 or $sampleEmails="all" are all valid.
# please edit $body variable within the code
###################################################################################################################


# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format yyyy-MM-dd #for logfile only
$starttime=Get-Date #need time also; don't use date from above

Write-Host "Processing `"$SearchBase`" for Password-Expiration-Notifications"
Write-Host "Testing Mode: $testing"

# Get Users From AD who are Enabled, Passwords Expire
Import-Module ActiveDirectory
Write-Host "Gathering User List"
$users = get-aduser -SearchBase $SearchBase -Filter {(enabled -eq $true) -and (passwordNeverExpires -eq $false)} -properties sAMAccountName, displayName, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress, lastLogon, whenCreated
Write-Host "Filtering User List"
### PURGING this option; seems to cause issue. # $users = $users | Where-Object {$_.DistinguishedName -notlike $ExcludeList}   ##also try -notmatch, needs heavy testing
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

$countprocessed=${users}.Count
$samplesSent=0
$countsent=0
$countnotsent=0
$countfailed=0

#set max sampleEmails to send to $adminEmailAddr
if ( $sampleEmails -isNot [int]) {
    if ( $sampleEmails.ToLower() -eq "all") {
    $sampleEmails=$users.Count
    } #else use the value given
}

if (($testing -eq $true) -and ($sampleEmails -ge 0)) {
    Write-Host "Testing only; $sampleEmails email samples will be sent to $adminEmailAddr"
} elseif (($testing -eq $true) -and ($sampleEmails -eq 0)) {
    Write-Host "Testing only; emails will NOT be sent"
}

# Create CSV Log
if ($logging -eq $true) {
    #Always purge old CSV file
    Out-File $logfile
    Add-Content $logfile "`"Date`",`"SAMAccountName`",`"DisplayName`",`"Created`",`"PasswordSet`",`"DaystoExpire`",`"ExpiresOn`",`"EmailAddress`",`"Notified`""
}

# Process Each User for Password Expiry
foreach ($user in $users) {
    $dName = $user.displayName
    $sName = $user.sAMAccountName
    $emailaddress = $user.emailaddress
    $whencreated = $user.whencreated
    $passwordSetDate = $user.PasswordLastSet
    $sent = "" # Reset Sent Flag

    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null) {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    } else {
        # No FGPP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }

    #If maxPasswordAge=0 then same as passwordNeverExpires, but PasswordCannotExpire bit is not set
    if ($maxPasswordAge -eq 0) {
        Write-Host "$sName MaxPasswordAge = $maxPasswordAge (i.e. PasswordNeverExpires) but bit not set."
    }

    $expiresOn = $passwordsetdate + $maxPasswordAge
    $today = (get-date)

    if ( ($user.passwordexpired -eq $false) -and ($maxPasswordAge -ne 0) ) {   #not Expired and not PasswordNeverExpires
        $daystoexpire = (New-TimeSpan -Start $today -End $expiresOn).Days
    } elseif ( ($user.passwordexpired -eq $true) -and ($passwordSetDate -ne $null) -and ($maxPasswordAge -ne 0) ) {   #if expired and passwordSetDate exists and not PasswordNeverExpires
        # i.e. already expired
        $daystoexpire = -((New-TimeSpan -Start $expiresOn -End $today).Days)
    } else {
        # i.e. (passwordSetDate = never) OR (maxPasswordAge = 0)
        $daystoexpire="NA"
        #continue #"continue" would skip user, but bypass any non-expiry logging
    }

    #Write-Host "$sName DtE: $daystoexpire MPA: $maxPasswordAge" #debug

    # Set verbiage based on Number of Days to Expiry.
    Switch ($daystoexpire) {
        {$_ -ge $negativedays -and $_ -le "-1"} {$messageDays = "has expired"}
        "0" {$messageDays = "will expire today"}
        "1" {$messageDays = "will expire in 1 day"}
        default {$messageDays = "will expire in " + "$daystoexpire" + " days"}
    }

    # Email Subject Set Here
    $subject="Action Required: H5G network password $messageDays"

    # Email Body Set Here, Note You can use HTML, including Images.
    $body="
    <p>Hello $dName!
    <br>
    <p>Your Active Directory password for account name <b>$sName</b> $messageDays. Please be sure to change your password to avoid any issues accessing company services.</p>

    <p>If you need instructions on how to change your password, you can refer to the Self Service guide.</p>

    Thank you,<br>
    Service Desk Dept <br>
    </p>
    "

    # If testing-enabled and send-samples, then set recipient to adminEmailAddr else user's EmailAddress
    if (($testing -eq $true) -and ($samplesSent -lt $sampleEmails)) {
        $recipient = $adminEmailAddr
    } else {
        $recipient = $emailaddress
    }

    #if in trigger range, send email
    if ( ($daystoexpire -ge $negativedays) -and ($daystoexpire -lt $expireindays) -and ($daystoexpire -ne "NA") ) {
        # Send Email Message
        if (($emailaddress) -ne $null) {
            if ( ($testing -eq $false) -or (($testing -eq $true) -and ($samplesSent -lt $sampleEmails)) ) {
                try {
                    Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop -ErrorVariable err
                } catch {
                    write-host "Error: Could not send email to $recipient via $smtpServer"
                    $sent = "Send fail"
                    $countfailed++
                } finally {
                    if ($err.Count -eq 0) {
                        write-host "Sent email for $sName to $recipient"
                        $countsent++
                        if ($testing -eq $true) {
                            $samplesSent++
                            $sent = "toAdmin"
                        } else { $sent = "Yes" }
                    }
                }
            } else {
                Write-Host "Testing mode: skipping email to $recipient"
                $sent = "No"
                $countnotsent++
            }
        } else {
            Write-Host "$dName ($sName) has no email address."
            $sent = "No addr"
            $countnotsent++
        }

        # If Logging is Enabled Log Details
        if ($logging -eq $true) {
            Add-Content $logfile "`"$date`",`"$sName`",`"$dName`",`"$whencreated`",`"$passwordSetDate`",`"$daystoExpire`",`"$expireson`",`"$emailaddress`",`"$sent`""
        }
    } else {
        #if ( ($daystoexpire -eq "NA") -and ($maxPasswordAge -eq 0) ) { Write-Host "$sName PasswordNeverExpires" } elseif ($daystoexpire -eq "NA") { Write-Host "$sName PasswordNeverSet" } #debug
        # Log Non Expiring Password
        if ( ($logging -eq $true) -and ($logNonExpiring -eq $true) ) {
            if ($maxPasswordAge -eq 0 ) {
                $sent = "NeverExp"
            } else {
                $sent = "No"
            }
            Add-Content $logfile "`"$date`",`"$sName`",`"$dName`",`"$whencreated`",`"$passwordSetDate`",`"$daystoExpire`",`"$expireson`",`"$emailaddress`",`"$sent`""
        }
    }

} # End User Processing

$endtime=Get-Date
$totaltime=($endtime-$starttime).TotalSeconds
$minutes="{0:N0}" -f ($totaltime/60)
$seconds="{0:N0}" -f ($totaltime%60)

Write-Host "$countprocessed Users from `"$SearchBase`" Processed in $minutes minutes $seconds seconds."
Write-Host "Email trigger range from $negativedays (past) to $expireindays (upcoming) days of user's password expiry date."
Write-Host "$countsent Emails Sent."
Write-Host "$countnotsent Emails skipped."
Write-Host "$countfailed Emails failed."

# sort the CSV file
if ($logging -eq $true) {
    Rename-Item $logfile "$logfile.old"
    import-csv "$logfile.old" | sort ExpiresOn | export-csv $logfile -NoTypeInformation
    Remove-Item "$logFile.old"
    Write-Host "CSV File created at ${logfile}."

    if ($testing -eq $true) {
        $body="<b><i>Testing Mode.</i></b><br>"
    } else {
        $body=""
    }

    $body+="
    <h1>Password Expiration Report</h1>
	<b>Report Date:</b> $date<br>
    <b>Search Scope:</b> `"$SearchBase`"<br>
	<b>Process Time:</b> $minutes minutes $seconds seconds<br>
	<b>Time Range:</b> $negativedays (past) to $expireindays (upcoming) days<br><br>
	
	<b><u>Results</b></u><br>
	<b>$countsent</b> Emails Sent.<br>
    <b>$countnotsent</b> Emails skipped.<br>
    <b>$countfailed</b> Emails failed.
    "


    try {
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $adminEmailAddr -subject "Password Expiry Logs" -body $body -bodyasHTML -Attachments "$logFile" -priority High -Encoding $textEncoding -ErrorAction Stop -ErrorVariable err
    } catch {
         write-host "Error: Failed to email CSV log to $adminEmailAddr via $smtpServer"
    } finally {
        if ($err.Count -eq 0) {
            write-host "CSV emailed to $adminEmailAddr"
        }
    }
}

# End