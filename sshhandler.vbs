' The aim of this script is to automatically execute an SSH login from KeePass using the current username and password.
' The KeePass entry URL should be: ssh://test.com (without username or password, as they are added automatically).

' Installation:
'   - Install WSL (tested with WSL2, Ubuntu 20), start bash and install sshpass
'   - Edit or empty the ConEmu path in the parameter below to adapt it to your configuration or to disable it
'   - Save this .vbs file on your PC, for example: C:\script\sshhandler.vbs
'   - Uncomment the debugging line below (line 87) for debugging
'   - Test it in cmd with:
'       cscript C:\script\sshhandler.vbs ssh://root:test@www.google.com:80
'   - KeePass URL Override:
'       cmd://wscript.exe C:\Script\sshhandler.vbs {URL:SCM}://{USERNAME}:{PASSWORD}@{URL:HOST}:{T-REPLACE-RX:/{URL:PORT}/-1/22/}
'   - Optional: add ciphers in /etc/ssh/ssh_config (test with "ssh -Q cipher | tr '\n' ',' | sed 's/,/, /g'")
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
If Wscript.Arguments.Count = 1 Then
	url = Wscript.Arguments(0)
Else
	exitWithError("Please pass only one parameter to this script:" & vbCrLf & "   - ssh://login:password@host:port " & vbCrLf & "login, password and port are optional")
End If

' Check if the URL is valid, else throw an error
If re.Test(url) Then
	log("URL is valid: " & url)
Else
	exitWithError(url & " is not a valid URL" & vbCrLf & "Please pass a parameter like:" & vbCrLf & "   - ssh://login:password@host:port " & vbCrLf & "   - telnet://login@host:port" & vbCrLf & "login, password and port are optional")
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

If protocol = "ssh" Then 
	paramProtocol = " ssh -o PreferredAuthentications=keyboard-interactive,password -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
Else
	exitWithError("Protocol: " & protocol & " is not supported (only ssh).")
End If 

If host <> "" Then 
	paramHost = " " & host
Else
	exitWithError("Host cannot be null.")
End If 

If login <> "" Then 
	paramLogin = " -l " & login
End If

If (pwd <> "") And (protocol <> "telnet") Then
	pwd = Replace(pwd, "'", "'\''")
	paramPwd = "SSHPASS='" & pwd & "' sshpass -e"
End If

If port <> "" Then 
	paramPort = " -p " & port
	port = ":" & port
End If

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
Function exitWithError(str)
	log(str)
	logIcon = vbCritical
	logTitle = "Error"
	outputLog()
	Wscript.Quit
End Function

' ***********
'   Logging 
' ***********
' Adds a message to the log String
Function log(str)
	If logResult = "" Then 
		logResult = str
	Else
		logResult = logResult & vbCrLf & str
	End If
End Function
' Outputs a msgBox including the log String
Function outputLog()
	If logResult <> "" Then
		MsgBox logResult, logIcon, logTitle
		WScript.StdOut.Write(logResult)
	End If
End Function
