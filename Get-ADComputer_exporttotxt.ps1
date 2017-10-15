#You can duplicate these two lines to search other OUs as well.
#You will have to go into the resultant server.txt with a program like notepad++ 
#and find and replace all spaces for it to work with the Get-ServerUniqueAccounts.ps1 script

Get-ADComputer -Filter * -SearchBase "OU=Computers,DC=contoso,DC=com"|
Select DNSHostName | ft -hidetableheaders | out-file .\servers.txt