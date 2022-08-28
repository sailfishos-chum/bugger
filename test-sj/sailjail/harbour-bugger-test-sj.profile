# -*- mode: sh -*-

# x-sailjail-translation-catalog = harbour-bugger
# x-sailjail-translation-key-description = permission-la-data
# x-sailjail-description = Bugger! permissions
# x-sailjail-translation-key-long-description = permission-la-data_description
# x-sailjail-long-description = Access necessary resources for Bugger! to work

# language detection

# detect user settings
# see https://github.com/sailfishos/nemo-qml-plugin-systemsettings/blob/master/src/localeconfig.cpp#L43
# we need to be able to read
# /home/.system/var/lib/environment/${UID}/locale.conf
# but no stanza in sailjail will make it work.
# but doing it in firejail config works
#
# use bare name without path here! it will look files in /etc/firejail
# include harbour-bugger.local

# for encrpytion detection, see Sailfish.Encryption/EncryptionService
whitelist /var/lib/sailfish-device-encryption/
read-only /var/lib/sailfish-device-encryption/

dbus-system.talk org.sailfishos.EncryptionService
dbus-system.call org.sailfishos.EncryptionService=org.sailfishos.EncryptionService.*@/*
dbus-system.broadcast org.sailfishos.EncryptionService=org.sailfishos.EncryptionService.*@/*

dbus-system.call org.freedesktop.EncryptionService=org.freedesktop.DBus.Introspectable.Introspect@/*

