## Bugger! log collect plugin system

Bugger! provides a systemd Target as well as a Service Template to facilitate
"plug-in" functionality for log gathering.

In order to add your script to the Bugger! log collector, do the following:

1. create a POSIX shell script which outputs logging to standard output
2. name the script `gather-logs-$YOURNAME.sh`
3. place the script into `/usr/share/harbour-bugger/scripts` and set it executable
4. use the systemd template service
   `harbour-bugger-gather-logs-plugin@.service` to add your script to the
   plugin service. I.e. do `systemctl --user enable
   harbour-bugger-gather-logs-plugin@$YOURNAME.service` The template adds a
   dependency on the `harbour-bugger-gather-logs.target` target, which is
   called by the app.

Notes:

 - Bugger! will run the log creation, but will not add the created log files in
   the app. Users will have to select them manually.
 - The script will be run from systemd with `/bin/sh -c "scriptname"`, so make
   sure its is /bin/sh compatible!
 - log output will be written to
   `~/Documents/YYYY-MM-DD_harbour-bugger-gather-logs-plugin@$YOURNAME.log`
 - `harbour-bugger-gather-logs-plugin@.service` uses `ProtectSystem=full`, so
   don't expect any location to be writable in your script.
 - scripts are run in systemd user scope. You can't be root. If you need to be
   root, use `pkexec` to prompt users for the lock code/fingerprint.


Of course, you are free to not use the Service Template and just depend on the
Target from any custom systemd services you have written.

If your log collecting script is part of a package, you can depend on
`harbour-bugger-gather-logs` to make sure the infrastructure is installed.

