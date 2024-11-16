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

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications
INSTALLS += desktop

qml.files = qml
qml.path = /usr/share/$${TARGET}

INSTALLS += qml

readme.files = README_logcollect.md
readme.path = /usr/share/$${TARGET}/scripts

INSTALLS += readme

OTHER_FILES += $$files(rpm/*)

include(translations/translations.pri)
include(systemd/systemd.pri)
include(contrib/contrib.pri)
include(icons/icons.pri)
include(sailjail/sailjail.pri)
