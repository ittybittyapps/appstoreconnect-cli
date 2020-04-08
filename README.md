![App Store Connect CLI - Interact with the App Store Connect API from the command line.](.github/logo.png)
# AppStoreConnect CLI

An easy to use command-line tool for interacting with the Apple AppStore Connect API.

AppStoreConnect CLI lets you interact with the AppStore Connect from the command line.

- Manage Users and access.
- Manage TestFlight Users, Beta Groups, and Builds.
- TODO: Provision Devices, Certificates, Profiles, and Bundle IDs.
- TODO: Download reports.

⚠️ **Note:** _AppStoreConnect CLI_ is under heavy development and not all features are complete.

## Installation

### TODO: Using [Homebrew](http://brew.sh/):

```sh
brew install appstoreconnect-cli
```

### Using [Mint](https://github.com/yonaskolb/mint):

```sh
mint install ittybittyapps/appstoreconnect-cli
```

### TODO: Using a pre-built binary:

You can also install AppStoreConnect-CLI by downloading binaries from the
[latest GitHub release](https://github.com/ittybittyapps/appstoreconnect-cli/releases/latest).

### Using Swift Package Manager:

#### On the Command Line

```sh
git clone https://github.com/ittybittyapps/appstoreconnect-cli.git
cd appstoreconnect-cli
swift run asc
```

#### As a Dependency

Add the following to your `Package.swift` file's dependencies:

```swift
.package(url: "https://github.com/ittybittyapps/appstoreconnect-cli.git", .branch("master")),
```

Then you can run:
```sh
swift run asc
```

## Road to 1.0

⚠️ Until 1.0 is reached, minor versions will be breaking.

## Usage

Run `asc --help` to see usage instructions.

```
$ swift run asc --help
OVERVIEW: A utility for interacting with the AppStore Connect API.

USAGE: asc <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  bundle-ids              Manage the bundle IDs that uniquely identify your apps.
  certificates            Create, download, and revoke signing certificates for app development and distribution.
  devices                 Register devices for development and testing.
  profiles                Create, delete, and download provisioning profiles that enable app installations for development and distribution.
  reports                 Download your sales and financial reports.
  testflight              Manage your beta testing program, including beta testers and groups, apps, and builds.
  users                   Manage users on your App Store Connect team.
```

## Authentication

_AppStoreConnect CLI_ requires the use of an AppStore Connect API Key. See the [Apple documentation][docs-api-key] for more details on how to create these keys.

When using _AppStoreConnect CLI_ commands you need to specify the API Key Issuer and API Key ID. This can be done via the `--api-issuer` and `--api-key-id` command line options or `APPSTORE_CONNECT_ISSUER_ID` and `APPSTORE_CONNECT_API_KEY_ID` environment variables respectively.

The API private key is expected to be named `AuthKey_<api-key-id>.p8` and located in one of the following directories:

- `./private_keys`
- `~/private_keys`
- `~/.private_keys`
- `~/.appstoreconnect/private_keys`

The API private key can also be stored in the environment variable `APPSTORE_CONNECT_API_KEY`.

[docs-api-key]: https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api