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

function WeakenPasswordPolicy(){
    secedit /export /cfg c:\windows\tasks\secpol.cfg
    (Get-Content C:\windows\tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\windows\tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\windows\tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force c:\secpol.cfg -confirm:$false
}

WeakenPasswordPolicy

$json = ( get-content $JSONFile | ConvertFrom-JSON)

$Global:Domain = $json.domain

foreach($group in $json.groups) {
    CreateADGroup $group


}

foreach ( $user in $json.users ){
    createADUser $user
}