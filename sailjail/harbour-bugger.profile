# -*- mode: sh -*-

# x-sailjail-translation-catalog = harbour-bugger
# x-sailjail-translation-key-description = permission-la-data
# x-sailjail-description = Bugger permissions
# x-sailjail-translation-key-long-description = permission-la-data_description
# x-sailjail-long-description = Access necessary resources for Bugger to work

# PERMISSIONS
# x-sailjail-permission = Base
include /etc/sailjail/permissions/Base.permission

# we need a read-only copy to read "arch" from
private-etc ssu/ssu.ini

# patchmanager detection parses this for enabled patches
private-etc patchmanager2.conf

# langua detection
whitelist /usr/share/jolla-supported-languages
read-only /usr/share/jolla-supported-languages
