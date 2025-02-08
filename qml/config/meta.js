.pragma library
/*
 * When adding a category, add it at the end!!
 * Don't use very long descriptions, they are shown in a button!
 * "None" should remain the first entry
 *
 * please keep 'help' types ordered, i.e. all tips next to each other, then all
 * links etc.  
 * supported help types: "link", "script", "tip"
 */
var data = {
    "categories": [
        {  "name": "none", "displayName": "None",
                "description": "No specific category",
                "help": []
        },
        {  "name": "android_app_support",  "displayName": "App Support",
                "description": "Android App Support, a.k.a. AD, Alien Dalvik",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Logs with Logcat",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Logs_with_Logcat/",
                    },
                ]
        },
        {  "name": "backup",   "displayName": "Backup",
                "description": "The Sailfish vault system",
                "help": []
        },
        {  "name": "bluetooth", "displayName": "Bluetooth",
                "description": "BT connection or devices",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on debugging Bluetooth",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Bluetooth_Logs/#scripts-to-enable-effective-debugging",
                    },
                    {
                        "type": "link",
                        "description":  "Help on Bluetooth pairing issues",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Bluetooth_Pairing/"
                    },
                    {
                        "type": "script",
                        "description":  "Increase logging level of Bluetooth service.",
                        "needsuser": "root",
                        "commands": [
                            "mkdir -p /etc/tracing/bluez",
                            "echo 'TRACING=\"--debug=*\"' >> /etc/tracing/bluez/bluez.tracing",
                            "systemctl restart bluetooth",
                        ],
                        "cleanup": [
                            "rm /etc/tracing/bluez/bluez.tracing",
                            "systemctl restart bluetooth",
                        ]
                    },
                    {
                        "type": "tip",
                        "description":  "Clean the bluez5 cache",
                        "text": [
                            "Stop the bluetooth service",
                            "Navigate to /var/lib/bluetooth",
                            "Navigate to the directory of your device",
                            "Examine potentially stale entries of the cache directory",
                            "Delete potentially stale entries of the cache directory",
                        ],
                        "links": []
                    },
                    {
                        "type": "tip",
                        "description":  "Disable the bluez5 cache feature (pairing issues)",
                        "text": [
                            "Navigate to /etc/bluetooth",
                            "Edit the file main.conf (keep a backup!)",
                            "Set the key 'Cache' to 'yes' instead of 'always'",
                            "Restart the bluetooth service",
                        ],
                        "links": []
                    },
                ]
        },
        {  "name": "browser",  "displayName": "Browser",
                "description": "Web browsing",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on debugging the Browser",
                        "link": "https://docs.sailfishos.org/Reference/Core_Areas_and_APIs/Browser/Working_with_Browser/#logging"
                    },
                ]
        },
        {  "name": "calendar", "displayName": "Calendar",
                "description": "Sync or management of events",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Sync logs",
                        "link": "https://docs.sailfishos.org/Develop/Collaborate/CalDAV_and_CardDAV_Community_Contributions/#sync-logs"
                    },
                ]
        },
        {  "name": "contacts", "displayName": "Contacts",
                "description": "Sync or management of contact information",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Sync logs",
                        "link": "https://docs.sailfishos.org/Develop/Collaborate/CalDAV_and_CardDAV_Community_Contributions/#sync-logs"
                    },
                ]
        },
        {  "name": "exchange", "displayName": "Exchange",
                "description": "Exchange/Outlook/Office356 accounts",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Active Sync/Email logs",
                        "link": "https://docs.sailfishos.org/Reference/Sailfish_OS_Cheat_Sheet/#email--active-sync-e-mail-debugging"
                    },
                ]
        },
        {  "name": "fingerprint",  "displayName": "Fingerprint",
                "description": "Recognition, management, sensor",
                "help": []
        },
        {  "name": "mail", "displayName": "EMail",
                "description": "General mail",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Email logs",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Email_Logs/"
                    }
                ]
        },
        { "name": "media_tracker", "displayName": "Media Indexing",
                "description": "Music, Image, and Video metadata",
                "help": []
        },
        { "name": "mobile_data",  "displayName": "Mobile Data",
                "description": "SIM cards, reception, roaming",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting oFono logs",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_oFono_Logs/"
                    }
                ]
        },
        { "name": "mpris", "displayName": "MPRIS",
                "description": "Media Player remote control",
                "help": []
        },
        { "name": "native_app","displayName": "Sailfish OS App",
                "description": "Sailfish stock apps",
                "help": []
        },
        { "name": "network",  "displayName": "Networking",
                "description": "General net and connectivity issues",
                "help": []
        },
        { "name": "ngfd", "displayName": "UI Feedback",
                "description": "Haptic feedback",
                "help": []
        },
        { "name": "oom_killer", "displayName": "OOM",
                "description": "Out-of-memory conditions",
                "help": [
                    {
                        "type": "tip",
                        "description":  "Use collectd for per-process monitoring",
                        "text": [
                            "Install collectd from SailfishOS Chum repository.",
                            "Or better, install SystemDataScope.",
                            "Navigate to /etc/collectd.d",
                            "Read the file processes.conf.example there",
                            "Copy file processes.conf.example to processes.conf",
                            "Edit processes.conf to monitor suspicious processes",
                            "Restart collectd.service (as user)",
                            "Wait for a couple of minutes",
                            "OpenSystemDataScope, execute Generate Definitions from its settings"
                        ],
                        "links": [
                            "https://sailfishos-chum.github.io/pkgs/collectd/",
                            "https://sailfishos-chum.github.io/apps/systemdatascope/"
                        ]
                    },
                ]
        },
        { "name": "positioning", "displayName": "Positioning",
                "description": "GPS and other geolocation methods",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Location Services logs",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Location_Services_Logs/"
                    },
                ]
        },
        { "name": "power",  "displayName": "Power Management",
                "description": "Battery drain, Power usage, Charging",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on investigating the cause of battery drain",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Battery_Lifetime/#monitoring-the-device"
                    },
                    {
                        "type": "tip",
                        "description":  "Use collectd for per-process monitoring",
                        "text": [
                            "Install collectd from SailfishOS Chum repository.",
                            "Or better, install SystemDataScope.",
                            "Navigate to /etc/collectd.d",
                            "Read the file processes.conf.example there",
                            "Copy file processes.conf.example to processes.conf",
                            "Edit processes.conf to monitor suspicious processes",
                            "Restart collectd.service (as user)",
                            "Wait for a couple of minutes",
                            "OpenSystemDataScope, execute Generate Definitions from its settings"
                        ],
                        "links": [
                            "https://sailfishos-chum.github.io/pkgs/collectd/",
                            "https://sailfishos-chum.github.io/apps/systemdatascope/"
                        ]
                    },
                ]
        },
        { "name": "flashing",  "displayName": "Flashing",
                "description": "Installing/flashing OS images",
                "help": [
                    {
                        "type": "link",
                        "description":  "Official Installation Instructions",
                        "link": "https://jolla.com/sailfishxinstall/"
                    },
                    {
                        "type": "link",
                        "description":  "Olf's Guide on installing Sailfish X",
                        "link": "https://gitlab.com/Olf0/sailfishX#guide-installing-sailfishx-on-xperias"
                    },
                ]
        },
        { "name": "adaptation",  "displayName": "Device Adaptation",
                "description": "Base support for a specific device, firmware etc.",
                "help": []
        },
        { "name": "lipstick",  "displayName": "Home Screen",
                "description": "Home Sceen, Launcher, etc",
                "help": []
        },
        { "name": "silica",  "displayName": "Silica",
                "description": "The Silica UI, and other Sailfish UI components",
                "help": []
        },
        { "name": "telephony",  "displayName": "Telephony",
                "description": "Issues with calls, reception, ...",
                "help": []
        },
        { "name": "camera",  "displayName": "Camera",
                "description": "Issues with taking photos or videos",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Camera logs",
                        "link": "https://docs.sailfishos.org/Reference/Sailfish_OS_Cheat_Sheet/#email--active-sync-e-mail-debugging"
                    },
                ]
        },
        { "name": "update",  "displayName": "System Update",
                "description": "Issues with upgrading the OS.",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on Update Failure Logs",
                        "link": "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_OS_Update_Failure_Logs/"
                    },
                ]
        },
        { "name": "audio",  "displayName": "Audio",
                "description": "Issues with sound output or recording",
                "help": [
                    {
                        "type": "link",
                        "description":  "Help on collecting Audio logs",
                        "link": "https://docs.sailfishos.org/Develop/Platform/Testing_Advice/#audio"
                    },
                ]
        },
    ]
}
// vim: ft=javascript expandtab ts=4 sw=4 st=4
