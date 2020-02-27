Enable RDP avec WMI

```
wmic /node:<computer name> process call create "cmd.exe /c netsh firewall set service RemoteDesktop enable"
```

et

```
wmic /node:<computer name> process call create 'cmd.exe /c reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f'
```
