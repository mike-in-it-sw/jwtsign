#!/usr/bin/env node

//Imports
const fs = require('fs');
const jwt = require('jsonwebtoken');
const yargs = require('yargs');

const options = yargs
 .usage("Usage: -n <name>")
 .option("k", {alias: "key", description: "Either a path to or string of your signing key", type: "string", demandOption: true})
 .option("t", {alias: "type", description: "The type of key being provided - file or string", type: "string", choices: ['file','string'], demandOption: true})
 .argv;


if(options.type == "string") {
  //options.key is a string so we don't need to do anything else - just assign it to our variable.
  var signingKey = options.key
} else {
  //options.key is a file so we need to read it then store it in our var.
  try {
    //read our file synchronously - wait for read before continuing.
    var signingKey = fs.readFileSync(options.key);
  } catch (e) {
    //something happened reading our file..
    if (e.code == 'ENOENT') {
      //...that something was file not found
      console.error('error: signing key ' + options.key + ' not found.');
      process.exit(1);
    } else {
      //... that something is who knows. Let's catchall and exit.
      console.error(e);
      process.exit(1);
    }//==>if/else e.code
  }//==>try/catch signingKey
}//==>if/else options.type

/*
//I didn't need additional headers beyond what jwt.sign already adds (alg and typ) so I didn't create specific. You may need to but according to Google
//documentation - it doesn't seem like you do: https://developers.google.com/identity/protocols/oauth2/service-account#httprest
var header = {
  alg: 'RS256',
  typ: 'JWT',
  key: 'value',
  key2: 'value',
}
*/

// Build our payload - 'exp' and 'iat' are unix epoch.  jwt.sign has a way to use string notation (1h, 2d, 3m, etc.) for this but it kept failing for me so I just went ahead used Math.floor.
// Get 'iss' 'aud' 'scp' values from the .json file provided by google. You could update this node app to include parameters for these values if you wanted.
// See previous link for what values are needed here.
var payload = {
  iss: '', 
  aud: '',
  exp: Math.floor(Date.now() / 1000) + (10 * 60), //expires - 1 hour - looks like google supports 1 hour as well (See previous link.)
  iat: Math.floor(Date.now() / 1000), //issued at - same as 'expires'
  scp: ''
}

try {
  //synchronously sign our JWt.
  //if you need additional headers beyond default then you should add the headers...
  // var jwtOut = jwt.sign(header, payload, signingKey, { algorithm: 'RS256' })
  var jwtOut = jwt.sign(payload, signingKey, { algorithm: 'RS256' })
} catch (e) {
  //something is wrong with jwt.sign - let's catch all
  console.error(e);
  process.exit(1);
}

//seems everything went OK - let's spit out our JWT
console.log(jwtOut);