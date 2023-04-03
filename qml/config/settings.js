.pragma library
var config = {
    "sources": {
        "os":  'file:///etc/sailfish-release',
        "hw":  'file:///etc/hw-release',
        "ssu": 'file:///etc/ssu/ssu.ini',
        "pm":  'file:///etc/patchmanager2.conf',
        "useruid": 100000
    },
    "submit": {
        "scheme":    'https',
        "host":      'forum.sailfishos.org',
        "uri":       '/new-topic?category_id=',
        "category_bugs":      '13',
        "category_features":  '23',
        "category_cbeta":     '21',
    },
    "upload": {
        "scheme":    'https',
        "host":      'forum.sailfishos.org',
        "uri":       '/uploads.json'
    },
    "gather": {
        "basename":     "harbour-bugger-gather-logs",
        "postfixes":    [ ".log", "_kernel.log" ],
        "prettynames":  [
            { "pattern": "/_kernel/",  "name": "Kernel" },
            { "pattern": "/_android/", "name": "Android" },
            { "pattern": "/_hybris/",  "name": "Hybris" },
        ]
    },
    "paste": {
        "scheme":    'https',
        "host":      'paste.mozilla.org',
        "uri":       '/api/',
        "expireDays": 182
    },
    "validation": {
        "minTitle":   20,
        "minDesc":    30,
        "minSteps":   30,
        "good":       150
    },
    "persistence": {
        "fieldKeys":    15,
        "saveInterval": 7000
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
