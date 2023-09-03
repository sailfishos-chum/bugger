.pragma library
var config = {
    "entries": [
       {
            "name": "ofono_verbose",
            "displayName": "Ofono deugging",
            "path": "/var/lib/environment/ofono/gather_logs.conf",
            "content": [ "OFONO_DEBUG=-d"]
        },
        {
            "name": "ohm_debug",
            "displayName": "OHM deugging",
            "path": "/etc/sysconfig/ohmd.debug",
            "content": [ "DEBUG_FLAGS='--verbose=all --trace=\"* format [%C:%L] ; * enabled;* target stdout;*.*=all\"'" ]

        }
    ]
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
