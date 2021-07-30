dir /a /s /b > c:\d4nk0st0rm\allpaths.txt
for /F "usebackq tokens=*" %A in ("c:\d4nk0st0rm\allpaths.txt") do @echo %~sA >> c:\d4nk0st0rm\eightpointthree.txt

