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
include harbour-bugger.local

# detect system settings
# see https://github.com/sailfishos/nemo-qml-plugin-systemsettings/blob/master/src/localeconfig.cpp#L50
private-etc locale.conf
private-etc locale.preferred.conf

# needed for LanguageModel
# see https://github.com/sailfishos/nemo-qml-plugin-systemsettings/blob/master/src/languagemodel.cpp#L45
whitelist /usr/share/jolla-supported-languages
read-only /usr/share/jolla-supported-languages

dbus-system.talk org.nemomobile.devicelock
dbus-system.call org.nemomobile.devicelock=org.nemomobile.lipstick.devicelock.state@/org/nemomobile/devicelock
whitelist /usr/share/lipstick/devicelock/devicelock_settings.conf
read-only /usr/share/lipstick/devicelock/devicelock_settings.conf

#whitelist /run/nemo-devicelock/socket

# we need a read-only copy to read "arch" from
private-etc ssu/ssu.ini

# patchmanager detection parses this for enabled patches
private-etc patchmanager2.conf

# BEG systemd manager and related
dbus-user.talk org.freedesktop.systemd1
dbus-user.call org.freedesktop.systemd1=org.freedesktop.systemd1@/*
dbus-user.talk *=org.freedesktop.systemd1
dbus-user.call *=org.freedesktop.systemd1.Manager@/*
dbus-user.call *=org.freedesktop.systemd1.Unit@/*
# END systemd manager and related
