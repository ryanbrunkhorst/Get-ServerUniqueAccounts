#Obtains date for the resultant serveraccounts_$CurrentDate.txt file
$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy-hh-mm-ss')
$servers = get-content "$PSScriptRoot\servers.txt"
foreach($server in $servers)
{
#Services
"Service Accounts on " + $server + "`n" | out-file $PSScriptRoot\serveraccounts_$CurrentDate.txt -Append
Get-WmiObject Win32_Service -ComputerName $server |
where-object {$_.StartName -ne ("LocalSystem")`
-And $_.StartName -ne ("NT Authority\NetworkService")`
-And $_.StartName -ne ("NT AUTHORITY\LocalService")`
-And $_.StartName -ne ($null)
}|
Select @{l="Server";e={$server}},DisplayName,StartName |
out-file $PSScriptRoot\serveraccounts_$CurrentDate.txt -Append

#Scheduled Tasks
"Scheduled Tasks Accounts on " + $server + "`n" | out-file $PSScriptRoot\serveraccounts_$CurrentDate.txt -Append
$schtask = schtasks.exe /query /s $server  /V /FO CSV |
ConvertFrom-Csv | Where { $_.TaskName -ne "TaskName" }

$schtask | where-object {
$_."Run as User" -ne ("SYSTEM")`
-And $_."Run as User" -ne ("INTERACTIVE")`
-And $_."Run as User" -ne ("LOCAL SERVICE")`
-And $_."Run as User" -ne ("NETWORK SERVICE")`
-And $_."Run as User" -ne ("Authenticated Users")`
-And $_."Run as User" -ne ("Administrators")`
-And $_."Run as User" -ne ("Users")`
-And $_."Run as User" -ne ("Everyone")`
-And $_."TaskName" -notlike ("*Optimize Start Menu Cache*")`
-And $_."TaskName" -notlike ("*User_Feed_Synchronization*")`
-And $_."Run as User" -ne ($null)
}|
select @{l="Server";e={$server}},"Run as User","Scheduled Task State",TaskName,"Task To Run"|
out-file $PSScriptRoot\serveraccounts_$CurrentDate.txt -Append

#User Profiles
"User Profiles on " +$server + "`n" | out-file $PSScriptRoot\serveraccounts_$CurrentDate.txt -Append
Get-WmiObject win32_userprofile -ComputerName $server|
where-object {$_.localpath -notlike ("*:\Windows\ServiceProfiles\*")`
-And $_.localpath -notlike ("*:\Windows\system32\*")
}|
select PSComputerName,localpath,lastusetime,status|
out-file $PSScriptRoot\serveraccounts_$CurrentDate.txt -Append

}