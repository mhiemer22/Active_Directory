# 02 creating AD Users

1. remotely connect to dc
```
$dc = New-PSSession 192.168.86.155 -Credential $creds
```
```
enter-pssession $dc
```

2. copy json file and ps1 to DC
```shell
Copy-Item .\ad_schema2.json -ToSession $dc C:\Windows\Tasks\
```
```
copy-Item .gen_ad.ps1 -ToSession $dc C:\Windows\Tasks\
```

3. Run the script (connect remotely to DC first) - specify json file
```
.\gen_ad.ps1
```

4. ad_schema2.json
```
```
{
    "domain": "xyz.com",

    "groups" : [
        {
           "name": "Employees" 
        }
    ],

    "users" : [

        {
            "name": "Bob Ob",
            "password": "P@ssword123",
            "groups": [
                "Employees"
            ]
        },
        {
            "name": "Alice Lice",
            "password": "P@sswordABC",
            "groups": [
                "Employees"
            ]
        }
    ]
}
```
