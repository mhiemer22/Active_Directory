# 01 Installing the Domain Controller

GIT COMMANDS
```shell
git add .
```
```shell
git commit
```
```shell
git push
```

1. use 'sconfig' to:
    - change the hostname
    - change the IP address to static
    - change the DNS server to our own IP address

2. Install the Active Directory Windows Feature

```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

3. Configure DNS IP
```shell
get-dnsclientserveraddress
```

```shell
set-dnsclientserveraddress -interfaceindex 4 -serveraddress 192.168.86.155
```

4. Add new workstation to domain
```
Add-Computer -DomainName xyz.com -Credential xyz\administrator -Force -Restart
```




