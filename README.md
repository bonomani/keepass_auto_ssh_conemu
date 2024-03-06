## Keepass_auto_ssh_conemu

### Description:
Keepass_auto_ssh_conemu is a script designed to enable SSH auto-login from Keepass via URL open, leveraging WSL2, Bash, sshpass, and ConEmu.

### Aim:
The script aims to execute a login from Keepass automatically, without requiring manual input of username and password. The Keepass entry's URL should be in the format `ssh://test.com` without any specified username and password, as they will be added automatically.

### Installation:

1. Install WSL (tested with WSL2, Ubuntu 20).
2. Start Bash and install sshpass:
    ```bash
    sudo apt-get install sshpass
    ```
3. Edit or empty the ConEmu path in `sshhandler.vbs` to adapt it to your current configuration or to disable it.
4. Save the `sshhandler.vbs` script on your PC, for example, at `C:\script\sshhandler.vbs`.
5. Uncomment the debugging line below (line 89) in `sshhandler.vbs` for debugging purposes.
6. Test the script in cmd with the following command:
    ```cmd
    cscript C:\script\sshhandler.vbs ssh://root:test@www.google.com:80
    ```
7. In Keepass, modify the URL Override with the following command:
    ```
    cmd://wscript.exe C:\script\sshhandler.vbs {URL:SCM}://{USERNAME}:{PASSWORD}@{URL:HOST}:{T-REPLACE-RX:/{URL:PORT}/-1/22/}
    ```
8. Optional (WSL2): Add old ciphers by running the following commands:
    ```bash
    mkdir ~/.ssh
    cd ~/.ssh
    vi config
    ```
   In the `config` file, add the following lines:
   ```
   KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1
   HostKeyAlgorithms +ssh-rsa,ssh-dss
   Ciphers +aes128-cbc,aes256-cbc,3des-cbc
   ```
