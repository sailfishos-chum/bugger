# -*- mode: sh -*-

# x-sailjail-translation-catalog = harbour-bugger
# x-sailjail-translation-key-description = permission-la-data
# x-sailjail-description = Bugger permissions
# x-sailjail-translation-key-long-description = permission-la-data_description
# x-sailjail-long-description = Access necessary resources for Bugger to work
x-sailjail-permission = Secrets

# we allow ourselves, and rpm (which we only use in -q mode anyway)

# TODO: this ia a copy of the real thing an will not be sunched with it!
# i.e. it will be out of date if repos change
private-etc ssu/ssu.ini
