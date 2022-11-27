## Bugger! log collect plugin system

In order to add your script for collecting logs to the Bugger! log collector, do the following:


1. create a shell script which outputs logging to standard output
2. place the script into `/usr/share/harbour-bugger/scripts`
3. name the script `gather-logs-$YOURNAME.sh`
4. use the systemd template service `harbour-bugger-gather-logs-plugin@.service` to add your script to the plugin service.
5. e.g. do `systemctl --user enable harbour-bugger-gather-logs-plugin@$YOURNAME.service`

Notes:

 - log output will be written to `~/Documents/YYYY-MM-DD-harbour-bugger-gather-logs-plugin_$YOURNAME.log`
 - `harbour-bugger-gather-logs-plugin@.service` uses `Protectsystem=full`, so don't expect any location to be writable in your script.
 - scripts are run in systemd user scope. You can't be root. If you need to be root, use `pkexec` to prompt users for the lock code/fingerprint.
 - Bugger! will run the log creation, but will not add the created log files in the app. Users will have to select them manually.
