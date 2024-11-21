######################################################################
# This is for icons and translation ONLY, use build.sh for building
######################################################################

TARGET = harbour-bugger
CONFIG += sailfishapp_qml
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

# sailfishapp takes care of this:
# desktop.files = $${TARGET}.desktop
# desktop.path = /usr/share/applications
# INSTALLS += desktop

# sailfishapp takes care of this:
# qml.files = qml
# qml.path = /usr/share/$${TARGET}
# INSTALLS += qml

lc_readme.files = README_logcollect.md
lc_readme.path = /usr/share/$${TARGET}/scripts
INSTALLS += lc_readme

OTHER_FILES += $$files(rpm/*)

include(translations/translations.pri)
include(systemd/systemd.pri)
include(contrib/contrib.pri)
include(svgs/icons.pri)
include(quickaction/quickaction.pri)
include(sailjail/sailjail.pri)
