.pragma library
var config = {
    "sources": {
        "os":  'file:///etc/sailfish-release',
        "hw":  'file:///etc/hw-release',
        "ssu": 'file:///etc/ssu/ssu.ini',
        "pm":  'file:///etc/patchmanager2.conf'
    },
    "submit": {
        "scheme":    'https',
        "host":      'forum.sailfishos.org',
        "uri":       '/new-topic?category_id=13'
    },
    "bugtemplate": {
        "host": "forum.sailfishos.org",
        "uri": "/c/13/show.json",
        "category": "category.topic_template"
    },
    "validation": {
        "minTitle":   20,
        "minDesc":    30,
        "minSteps":   30,
        "good":       150
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4