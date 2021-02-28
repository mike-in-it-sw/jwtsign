# jwtsign
https://community.spiceworks.com/topic/2308516-creating-a-jwt-request-for-first-issue-with-a-json-key-file?from_forum=356

* Install NodeJS - https://nodejs.org/en/download/
* Clone this repository or download as Zip - https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository
* Open cmd prompt
  * Browse to the cloned repo folder on your machine (or the extracted .zip location)
    * Example: cd C:\temp\repos\jwtsign
  * Globally install the nodejs app so powershell can call it.
    * npm install -g
    * REMINDER: to run the above command you must be in the jwtsign directory on your local machine.
* Modify 'payload' section of index.js with required details in Google provided .json file
* Review/edit 'using_with_powershell.ps1' file, then launch the script.

## Assumptions
* using_with_powershell.ps1 will NOT actually work calling Google out of the box.
* The sample provided is to show you how to get the JWT so you CAN call Google token endpoint to get an access token.
  * Only after calling 'token' endpoint to get an access token can you then call subsequent google API endpoints.
* All samples included in the rsa_samples directory are randomly generated keys in PCKS1 and 8 format. Just for your testing.