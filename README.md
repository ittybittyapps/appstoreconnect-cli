# appstoreconnect-cli

A tool for interacting with the Apple AppStore Connect API from the command line.

## Authentication
The default location for an `auth.yml` file is `config/auth.yml`. It's format should look like:

```yml
issuerID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
privateKeyID: xxxxxxxxxx
privateKey: AAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBB/C
```

If you choose not to put the auth file here you can specify it but using the auth argument:

`appstoreconnect-cli [other-args] auth path/to/auth.yml`

## Running (Debug)
The tool can be run by invoking the command:

`swift run appstoreconnect-cli [args]`

A convenience script can also invoke this for you by running:

`./appstoreconnect-cli [args]`