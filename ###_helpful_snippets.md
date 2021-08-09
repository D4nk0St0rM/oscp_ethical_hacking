### snippets that help 


nmap banners and vulns
```
sudo nmap --script='vuln,banner'
```

nmap gnmap format - open ports
```
awk '{for(i=5;i<=NF;i++)if($i~"/open/"){sub("/.*","",$i); print $2" "$i}}'
```

curl like a search engine bot (blocked robots.txt)
```
curl -A "'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)')" http://website/robots.txt
```


