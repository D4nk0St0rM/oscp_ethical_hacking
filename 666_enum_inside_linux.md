
#### find writable files and directories

```
find / -type f \( -perm -g+w -or -perm -o+w \) -exec ls -adl {} \; > f_find.txt
find / -type d \( -perm -g+w -or -perm -o+w \) -exec ls -adl {} \; > d_find.txt
```



#### handy commands

| Header | Description | Command |
| --------------- | --------------- | --------------- |
| Information gathering| Contains DNS servers | /etc/resolv.conf |
| | Message of the day | / etc / motd |
| | version of the distribution | / etc / issue |
| | List of users | / etc / passwd | 
| | User hashes list (requires root permissions) | / etc / shadow | 
| | It shows you the commands executed by the user | /home/USER/.bash_history | 
|System | Shows kernel, architecture and distribution information | join me | 
| | List of running processes | ps aux | 
| | Current user and groups to which it belongs | go | 
| | Processor architecture | uname -m | 
| | Users online | w | 
| | uptime, runlevel, tty, processes, etc. | who -a | 
| | GCC version | gcc -v | 
| | MySQL version | mysql –version | 
| | perl version | perl -v | 
| | ruby version | ruby -v | 
| | python version | python –version | 
| | Mounted file systems | df -k | 
| | File system mountedps | mount | 
| | Last connected users | last -a | 
| | Get SElinux status | getenforce | 
| | Displays information about the last system boot | dmesg | 
| | List all PCI devices | lspci | 
| | List all USB devices | lsusb | 
| | Displays the CPU information | lscpu | 
| | Hardware information list | lshw | 
| | Displays information about the CPU | cat / proc / cpuinfo | 
| | Displays information about memory | cat / proc / meminfo | 
| | Shows the total capacity for a directory | du -h –max-depth = 1 / | 
| | Locate where the NMAP command is | which nmap | 
| | Locate where the NMAP command is | locate bin / nmap | 
| | Locate where the NC command is | locate bin / nc | 
| | Java version | java -version | 
|Networking | Server name | hostname -f | 
| | shows IP addressing | ip addr show | 
| | Shows IP and gateway addressing | ip ro show | 
| | Shows all interfaces with their IP address | ifconfig -a | 
| | Information about the routes | route -n | 
| | Network configuration under Debian-based distributions | cat / etc / network / interfaces | 
| | Show iptables rules | iptables -L -n -v | 
| | Our iptables NAT rules | iptables -t nat -L -n -v | 
| | Show ipv6 rules from iptables | ip6tables -L -n -v | 
| | Save existing rule set | iptables-save | 
| | List all established connections | netstat -anop | 
| | Information about the routes | netstat -r | 
| | Connections established with sockets | netstat -nltupw | 
| | Show the ARP table | harp | 
| | Shows the process and established connection | lsof -nPi | 
| | more discreet, all the information provided by the above commands can be found by searching the files in / proc / net, and this approach is less likely to trigger monitoring or other things | cat / proc / net / * | 
|User accounts | Show all local users | cat / etc / passwd | 
| | User hashes list (requires root permissions) | cat / etc / shadow | 
| | List of user hashes on AIX | / etc / security / passwd | 
| | List the groups | cat / etc / group | 
| | Dump information from all local users, LDAP and NIS | getent passwd | 
| | Dumps information about all local groups, LDAP and NIS | getent group | 
| | SAMBA database | pdbedit -L -w | 
| | SAMBA database | pdbedit -L -v | 
| | Email aliases | cat / etc / aliases | 
| | Look for aliases within the / etc directory | find / etc -name aliases | 
| | List of aliases | getent aliases | 
| | Shows the NIS password file | ypcat passwd | 
|Get information from users | List all files within / home directories | ls -alh / home / * / | 
| | Lists ssh content inside / home directories | ls -alh /home/*/.ssh/ |
| | List all crontab files of all users | for user in $ (cut -f1 -d: / etc / passwd);do echo $ user; crontab -u $ user -l; done |
| | Show authorized_keys inside / home directories | cat /home/*/.ssh/authorized_keys | 
| | Show DSA keys inside / home directories | cat /home/*/.ssh/known_hosts | 
| | Show the history of all users | cat /home/*/.hist | 
| | Search inside / home for .vnc or .subversion files | find /home//.vnc /home//.subversion -type f | 
| | Search within history strings that contain ssh | grep ^ ssh /home/*/.hist | 
| | Search within history strings that contain telnet | grep ^ telnet `/home/*/.hist` | 
| | Search inside history strings that contain mysql | grep ^ mysql /home/*/.hist | 
| | display the content of the .viminfo file | cat /home/*/.viminfo | 
| | Show the permissions a user has with sudo | sudo -l | 
| | List scheduled tasks | crontab -l | 
| | Show the contents of the .mysql_history file | cat /home/*/.mysql_history | 
|Credentials | SSH keys, often without a password | / home / /.ssh/id | 
| | Kerberos tickets | / tmp / krb5cc_ * | 
| | Kerberos tickets | /tmp/krb5.keytab | 
| | PGP keys | /home/*/.gnupg/secring.gpgs | 
|Configuration files | Show all configuration files | ls -aRl / etc / * awk '$ 1 ~ /w.$/' * grep -v lrwx 2> / dev / nullte | 
| | version of the distribution | cat /etc/issue[,.net} | 
| | Contains FreeBSD encrypted hashes | cat /etc/master.passwd | 
| | Show local groups | cat / etc / group | 
| | get a relationship between a hostname and an IP address | cat / etc / hosts | 
| | crontab configuration file | cat / etc / crontab | 
| | Kernel configuration file | cat /etc/sysctl.conf | 
| | DNS configuration file | cat /etc/resolv.conf | 
| | Syslog configuration file | cat /etc/syslog.conf | 
| | Apache service configuration file | cat /etc/http.conf | 
| | Lighttpd service configuration file | cat /etc/lighttpd.conf | 
| | Printer service configuration file | cat /etc/cups/cupsd.confcda | 
| | Network "supervisor" configuration file | cat /etc/inetd.conf | 
| | Apache configuration file for XAMPP service | cat /opt/lampp/etc/httpd.conf | 
| | SAMBA service configuration file | cat /etc/samba/smb.conf | 
| | OpenLDAP service LDAP configuration file | cat /etc/openldap/ldap.conf | 
| | LDAP configuration file | cat /etc/ldap/ldap.conf | 
| | File where NFS shared directories are exported | cat / etc / exports | 
| | NIS configuration file | cat /etc/auto.master | 
| | NIS configuration file | cat / etc / auto_master | 
| | Configuration file where all file systems are mounted | cat / etc / fstab | 
|Determine the distribution | We can see the distro in most Linux | join me | 
| | Generic command for all LSB distributions | lsb_release -d | 
| | Generic for distributions using "systemd" | / etc / os-release | 
| | Generic but often modified | / etc / issue | 
| |  | cat / etc / * release | 
| | Suse | / etc / SUSE-release | 
| | Red hat | / etc / redhat-release, / etc / redhat_version | 
| | Fedora | / etc / fedora-release | 
| | Slackware | / etc / slackware-release, / etc / slackware-version | 
| | Debian | / etc / debian_release, / etc / debian_version | 
| | Mandrake | / etc / mandrake-release | 
| | Sun JDS | / etc / sun-release | 
| | Solaris / Sparc | / etc / release | 
| | Gentoo | / etc / gentoo-release | 
| | Arch Linux | / etc / arch-release | 
| | OpenBSD; sample: "OpenBSD.amd64" | arch | 
|Get a shell after doing a reverse shell | Get shell using python | python -c 'import pty; pty.spawn ("/ bin / bash")' | 
| | Get shell using Linux command | echo os.system ('/ bin / bash') | 
| | Get shell using SH | / bin / sh -i | 
| | Get shell using perl | perl -e 'exec "/ bin / sh";' | 
| | Get shell using perl | perl: exec "/ bin / sh"; | 
| | Get shell using ruby | ruby: exec "/ bin / sh" | 
| | Get shell using exec | exec "/ bin / sh" | 
| | Get shell using Linux command | :! bash | 
| | Get shell using Linux command | : set shell = / bin / bash: shell | 
| | Get shell using Linux command | ! sh | 
|Installed packages | Red hat-based distributions | rpm -qa –last | head | 
| | Red hat-based distributions | yum list | grep installed | 
| | Debian based distributions | dpkg -l | 
| | Debian based distributions | dpkg -l | grep -i "linux-image" | 
| | Debian based distributions | dpkg –get-selections | 
| | Solaris | pkginfo | 
| | Gentoo | cd / var / db / pkg / && ls -d / | 
| | Arch Linux | pacman -Q | 





