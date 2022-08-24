######################################################################
# This is for icons and translation ONLY, use build.sh for building
######################################################################

TARGET = harbour-bugger
CONFIG += sailfishapp sailfishapp_i18n
INCLUDEPATH += .

lupdate_only {
SOURCES += \
    qml/$${TARGET}.qml \
    qml/pages/*.qml \
    qml/cover/*.qml \
    qml/components/*.qml \
    qml/config/*.js

}

# if we have a binary:
#SOURCES += src/main.cpp

TRANSLATIONS += translations/$${TARGET}-en.ts \
                translations/$${TARGET}-de.ts \
                translations/$${TARGET}-sv.ts \

include(translations/translations.pri)
include(icons/icons.pri)
include(sailjail/sailjail.pri)
