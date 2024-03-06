Keepass_auto_ssh_conemu
- ssh auto-login from Keepass (url open) with the use of wsl2, bash, sshpass and conemu

The aim of this script is to execute a login from keepass with current user/pass automaticaly:
The url of the keepass entry should be: ssh://test.com without any username and password as they will be added automatically. 

Installation:
- Install WSL (tested with wsl2, ubuntu 20), start bash and install sshpass (sudo apt-get install sshpass)
- Edit or empty the ConEmu path in sshhandler.vbs to adapt it to your current configuration or to disable it
- Save this .vbs on your PC like c:\script\sshhandler.vbs 
- Uncomment debugging line below (line 89) in sshhandler.vbs for debugging
- Test it with in cmd with "cscript c:\script\sshhandler.vbs ssh://root:test@www.google.com:80"
- In Keepass modify the URL Override with: cmd://wscript.exe C:\script\sshhandler.vbs {URL:SCM}://{USERNAME}:{PASSWORD}@{URL:HOST}:{T-REPLACE-RX:/{URL:PORT}/-1/22/}
- Optional in WSL2: Add old cyphers (test cipher:"ssh -Q cipher | tr '\n' ',' | sed 's/,/, /g'")
  - mkdir ~/.ssh
  - cd ~/.ssh
  - edit a file: vi config (or alternate)
    ```
    KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1
    HostKeyAlgorithms +ssh-rsa,ssh-dss
    Ciphers +aes128-cbc,aes256-cbc,3des-cbc 
    ```
