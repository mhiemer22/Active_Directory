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
5. gen_ad powershell
```
param( [Parameter(Mandatory=$true)] $JSONFile )

function CreateADGroup (){
    param( [Parameter(Mandatory=$true)] $groupObject )

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
}

function CreateADUser(){
        param( [Parameter(Mandatory=$true)] $userObject )

# Pull out the name from the JSON object
$name = $userObject.name
$password = $userObject.password

# Generate a "first inital, last name" structure for username
$firstname, $lastname = $name.Split(" ")
$username = ($firstname[0] + $lastname).ToLower()
$samAccountName = $username
$principalname = $username

# Actually create AD user object
New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountname $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Passthru | Enable-ADAccount

    # Add the user to its appropriate group
    foreach($group_name in $userObject.groups) {

        try {
            get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning "User $name NOT added to group $group_name because it does not exist"
        }
        
    }
}

$json = ( get-content $JSONFile | ConvertFrom-JSON)

$Global:Domain = $json.domain

foreach($group in $json.groups) {
    CreateADGroup $group


}

foreach ( $user in $json.users ){
    createADUser $user
}
```