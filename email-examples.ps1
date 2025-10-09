# Gmail SMTP with interactive credential prompt
Send-MailMessage -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl -Credential (Get-Credential) -From "your-email@gmail.com" -To "recipient@example.com" -Subject "CSV Report" -Body "Please find the attached CSV file." -Attachments "C:\path\to\your\file.csv"

# Outlook/Hotmail SMTP
Send-MailMessage -SmtpServer "smtp-mail.outlook.com" -Port 587 -UseSsl -Credential (Get-Credential) -From "your-email@outlook.com" -To "recipient@example.com" -Subject "CSV Report" -Body "Please find the attached CSV file." -Attachments "C:\path\to\your\file.csv"

# With hardcoded credentials (less secure but no prompt)
Send-MailMessage -SmtpServer "smtp.zoho.com.cn" -Port 587 -UseSsl -Credential (New-Object System.Management.Automation.PSCredential("kenyluk@zohomail.cn", (ConvertTo-SecureString "demmi0-pugDyz-ciksyp" -AsPlainText -Force))) -From "kenyluk@zohomail.cn" -To "keny_luk@chk.canon.com.hk" -Subject "CSV Report" -Body "Please find the attached CSV file." -Attachments "C:\Users\Keny\PycharmProjects\OnelinePowerShell\31350092520250611.ACL"

# Corporate Exchange Server (adjust server and port as needed)
Send-MailMessage -SmtpServer "mail.company.com" -Port 25 -Credential (Get-Credential) -From "your-email@company.com" -To "recipient@example.com" -Subject "CSV Report" -Body "Please find the attached CSV file." -Attachments "C:\path\to\your\file.csv"

# Yahoo SMTP
Send-MailMessage -SmtpServer "smtp.mail.yahoo.com" -Port 587 -UseSsl -Credential (Get-Credential) -From "your-email@yahoo.com" -To "recipient@example.com" -Subject "CSV Report" -Body "Please find the attached CSV file." -Attachments "C:\path\to\your\file.csv" 