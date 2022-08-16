######################################################################
# This is for translation ONLY, use build.sh for building
######################################################################

TEMPLATE = aux
TARGET = systemd-watcher
CONFIG += lrelease

lupdate_only {
SOURCES += \
    $${_PRO_FILE_PWD_}/$${TARGET}.qml \
    $${_PRO_FILE_PWD_}/cover/*.qml \
    $${_PRO_FILE_PWD_}/pages/*.qml \
    $${_PRO_FILE_PWD_}/components/*.qml \

}

# Input
EXTRA_TRANSLATIONS += $${_PRO_FILE_PWD_}/../translations/$${TARGET}-en.ts \
                      $${_PRO_FILE_PWD_}/../translations/$${TARGET}-de.ts \
