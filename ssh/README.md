#### dehash known_hosts

The first base64 encoded string is used as the salt
The second string is the IP address

##### convert the hashed known_hosts file into a format for hashcat
```
python3 kh-converter.py known_hosts > hosts_hashcat
```

##### crack the "HMAC-SHA1 (key = $salt)" hashes
```
hashcat -m 160 --quiet --hex-salt hosts_hashcat -a 3 ipv4_hcmask.txt
```
