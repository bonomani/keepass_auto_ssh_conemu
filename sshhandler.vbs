' The aim of this script is to execute a login from keepass with current user/pass automaticaly:
' the url of the keepass entry should be: ssh://test.com without any username and password as they will be added automatically. 

' Installation:
'   - Install WSL (tested with wsl2, ubuntu 20), start bash and install sshpass
'   - Edit or empty the ConEmu path in parameter below to adapt it to your current configuration or to disable it
'   - Save this .vbs on your PC like c:\script\sshhandler.vbs 
'   - Uncomment debugging line below (line 89) for debugging
'   - Test it with in cmd with "cscript c:\script\sshhandler.vbs ssh://root:test@www.google.com:80"
'   - Keepass URL Override: cmd://wscript.exe C:\Script\sshhandler.vbs {URL:SCM}://{USERNAME}:{PASSWORD}@{URL:HOST}:{T-REPLACE-RX:/{URL:PORT}/-1/22/}
'   - Optional: Add cyphers at the of the file /etc/ssh/ssh_config (test witch "ssh -Q cipher | tr '\n' ',' | sed 's/,/, /g'"
'      - KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1
'      - Ciphers +aes128-cbc,3des-cbc 

' Version 2021-18-07'
' Script Created by Bruno Manzoni Based on the putty script from Sebastien Biffi

On Error Resume Next
' initialisation of variables
logResult = "" ' Used for logging purpose during debug or in case of error. Log is a msgBox
logIcon = 0 ' Icon of the MsgBox. By default: none
logTitle = "" ' Title of the MsgBox. By default: none

Set re = New RegExp
' The pattern that matches the URL. Used to check the URL format provided and find fields in it.
re.Pattern = "^([^:]+)://(([^:]+)(:(.*))?@)?(([^/@:]+)(:([0-9]+))?)/?$"

' Check if only 1 parameter is passed to the script, else throw an error
if Wscript.Arguments.Count = 1 then
	url = Wscript.Arguments(0)
else
	exitWithError("Please pass only 1 parameter to this script like:" & vbCrLf & "   - ssh://login:password@host:port " & vbCrLf & "login, password & port are optional")
end if

' Check if the URL is valid, else throw an error
If re.Test(url) Then
	log("URL is valid: " & url)
Else
	exitWithError(url & " is NOT a valid URL" & vbCrLf & "Please pass only 1 parameter to this script like:" & vbCrLf & "   - ssh://login:password@host:port " & vbCrLf & "   - telnet://login@host:port" & vbCrLf & "login, password & port are optional")
End If

' Find the putty parameters in the URL
Set Matches = re.Execute(url)
protocol = Matches.Item(0).Submatches(0)
login = Matches.Item(0).Submatches(2)
pwd = Matches.Item(0).Submatches(4)
host = Matches.Item(0).Submatches(6)
port = Matches.Item(0).Submatches(8)
log("  host: " & host)
log("  protocol: " & protocol)
log("  port: " & port)
log("  login: " & login)
log("  pwd: " & pwd)

if protocol = "ssh" then 
	paramProtocol = " ssh -o PreferredAuthentications=keyboard-interactive,password -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
else
	exitWithError("Protocol: " & protocol & " is not the ssh protocol.")
end if 
if host <> "" then 
	paramHost = " " & host
else
	exitWithError("Host cannot bu null.")
end if 
if login <> "" then 
	paramLogin = " -l " & login
end if
if (pwd <> "") and (protocol <> "telnet") then 
	paramPwd = "sshpass -p " & pwd
end if
if port <> "" then 
	paramPort = " -p " & port
	port = ":" & port
end if

' build the ssh command like:
' sshpass -p password ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l user -p 8080 www.google.com
sshCommand = paramPwd & paramProtocol & paramLogin & paramPort & paramHost

' Add bash or ConEmu
bash = """C:\Program Files\ConEmu\ConEmu64.exe"" -Reuse -run bash.exe" 'ConEmu
bash_start = " -c """ 'Bash & ConEmu with doublequote
bash_end = """ -new_console:p5t:" & protocol & "://" & host & port  'with doublequote

sshCommand = bash & bash_start & sshCommand & bash_end
log (sshCommand)

' For debugging purpose, uncomment following line:
'outputLog()

' Execute ssh
Set objShell = CreateObject("WScript.Shell")
objShell.Run sshCommand,1,False

' ****************
'   Error Output
' ****************
' Outputs a msgBox including the log and the error message
function exitWithError(str)	
	log(str)
  logIcon = vbCritical
	logTitle = "Error"
	outputLog()	
	wscript.Quit
end function

' ***********
'   Logging 
' ***********
' Adds a message to the log String
function log(str)
	if logResult = "" then 
		logResult = str
	else
		logResult = logResult & vbCrLf & str
	end if
end function
' Outputs a msgBox including the log String
function outputLog()
	if logResult <> "" then
		MsgBox logResult, logIcon, logTitle
		WScript.StdOut.Write(logResult)
	end if
end function
