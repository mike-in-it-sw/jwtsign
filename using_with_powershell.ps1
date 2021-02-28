<#
SAMPLE RSA KEYS
    These keys were generated for testing using OpenSSL.  These are not actual keys.
    Those appended with _stringified are json.stringify versions of RSA keys - which is what you'd see in the google provided .json file containing your key.
    $pkcs1_stringified = Get-Content "$PSScriptRoot\rsa_samples\rsa_sample_pkcs1_stringified.txt"
    $pkcs1 = Get-Content "$PSScriptRoot\rsa_samples\rsa_sample_pkcs1.txt"
    $pkcs8_stringified = Get-Content "$PSScriptRoot\rsa_samples\rsa_sample_pkcs8_stringified.txt"
    $pkcs8 = Get-Content "$PSScriptRoot\rsa_samples\rsa_sample_pkcs8.txt"
#>

<#
Sample Google provided JSON file when generating api keys in cloud console
Don't worry, the "private_key" value is the sample rsa_sample_pkcs8_stringified.txt
    \rsa_samples\google-sample-key.json
#>

#get all the inforomation from the google provided json file and store as a PS object - useful later if you need more data from it.
$gInfo = Get-Content -Path "$PSScriptRoot\rsa_samples\google-sample-key.json" -Raw | ConvertFrom-Json #ConvertFrom-Json also acts as a json.parse() where it will 'reverse' the effects of json.stringifiy() which was used to create the .json file and 'malforms' the included key.
$key = $gInfo.private_key

<# or as a one-liner if you don't use $gInfo 
#Stringified keys will need to be converted from json to their 'normalized' string using ConvertFrom-Json
$key = (Get-Content -Path "$PSScriptRoot\rsa_samples\google-sample-key.json" -Raw | ConvertFrom-Json).private_key
#>

#now we can call the nodejs app..Remember -k parameter must be a well-formed PEM, not a json.stringify string.
$jwt = jwtsign -k $key -t string 2>&1
$jwt #take this output to jwt.io and you can verify the information. If you use openssl to take your UNSTRINGIFIED version of the private_key and make export the public key you can validate the signature as well.
<#
In the above snippet we're using stream redirection (2>&1) to take the stderr stream from the nodejs app (the '2') and redirecting it to powershells 'success' stream (&1). https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.1
Any errors that are thrown on this line are from the nodejs app and should be fixed there, not in powershell script.

Since we're re-directing to the success out, we should handle errors. 

We do this using $? automatic variable since in our Node.JS we are sending process.exit(1) return codes if errors exist which in powershell would return a 'false'.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.1
#>
if($?) {
    #our NodeJS app returned 0 on the exit code (success) so let's try and get our token
    ##NOTE## Everything below is UNTESTED/hypothetical against Google service.  What you're doing here is the "Making the access token request" part of the documented link.
    $postReq = @{
        grant_type = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
        assertion = $jwt
    }
    $postContentType = "application/x-www-form-urlencoded"
    #try/catch wouuld likely be best here but it's just a sample....
    $accessReq = Invoke-RestMethod -uri $gInfo.token_uri -Method Post -body $postReq -ContentType $postContentType
    #if successful we shoulud get an access_token in the json resposne body...
    if($accessReq.access_token) {
        #sweet, now we can actually call the api endpoints...
        $endpointHeader = @{
            Authorization = "Bearer $($accessReq.access_token)"
        }
        $callGDrive = Invoke-RestMethod -uri 'https://www.googleapis.com/drive/v2/files' -Headers @endpointHeader
    } else {
        #well crap, something went wrong when trying to get our access token from google.
        #what do you do?
    }


} else {
    #nodeJS app returned a non-zero number on the exit code (likly a 1 since that's what we coded). This is a critical error and we should throw/stop the script.
    throw $jwt
}
