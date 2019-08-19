# FiveM-Updater
> Automatic Updater scripts for FiveM.

This script will simply download the latest server version of FiveM when it is run.

## Requirements

### Windows:

* Powershell (tested with v6 in Windows 10)

### Linux:

TBD

## Usage

**NOTE: Configuration is located in the script. Edit this before using!**

FXServer *must* be stopped before executing an update.

### Windows:

```sh
powershell -ExecutionPolicy Bypass -File .\FiveM-Update.ps1 [-Silent]
```

Specify `-Silent` flag to not prompt you to download. Useful when running as a scheduled task.

### Linux:

TBD

## Meta

Nathan C. – Discord: Era#1337

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/nathanctech/FiveM-Updater](https://github.com/nathanctech/FiveM-Updater)

## Contributing

1. Fork it (<https://github.com/nathanctech/FiveM-Updater/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request