![App Store Connect CLI - Interact with the App Store Connect API from the command line.](https://user-images.githubusercontent.com/1712450/77729642-4c204080-7053-11ea-9c0b-e21218c70c8c.png)


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