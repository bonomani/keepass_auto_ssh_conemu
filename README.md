Keepass_auto_ssh_conemu
Keepass auto-login with ssh in ConEmu (use wsl2, bash, sshpass)

The aim of this script is to execute a login from keepass with current user/pass automaticaly:
The url of the keepass entry should be: ssh://test.com without any username and password as they will be added automatically. 

Installation:
- Install WSL (tested with wsl2, ubuntu 20), start bash and install sshpass (sudo apt-get install sshpass)
- Edit or empty the ConEmu path in parameter below to adapt it to your current configuration or to disable it
- Save this .vbs on your PC like c:\script\sshhandler.vbs 
- Uncomment debugging line below (line 89) for debugging
- Test it with in cmd with "cscript c:\script\sshhandler.vbs ssh://root:test@www.google.com:80"
- Keepass URL Override: cmd://wscript.exe C:\Script\sshhandler.vbs {URL:SCM}://{USERNAME}:{PASSWORD}@{URL:HOST}:{T-REPLACE-RX:/{URL:PORT}/-1/22/}
- Optional: Add cyphers at the of the file /etc/ssh/ssh_config (test witch "ssh -Q cipher | tr '\n' ',' | sed 's/,/, /g'"
  - KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1
  - Ciphers +aes128-cbc,3des-cbc 
