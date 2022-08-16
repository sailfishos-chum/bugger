######################################################################
# This is for translation ONLY, use build.sh for building
######################################################################

TARGET = harbour-bugger
CONFIG += sailfishapp sailfishapp_i18n
INCLUDEPATH += .

lupdate_only {
SOURCES += \
    qml/$${TARGET}.qml \
    qml/pages/*.qml \
    qml/cover/*.qml \
    qml/components/*.qml

}

# if we have a binary:
#SOURCES += src/main.cpp

TRANSLATIONS += translations/$${TARGET}-en.ts \
                translations/$${TARGET}-de.ts \

#include(icons/icons.pri)
