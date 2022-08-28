TEMPLATE = aux
#CONFIG += sailfishapp
INCLUDEPATH += .

QT -= core gui

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications
INSTALLS += desktop

qml.files = qml
qml.path = /usr/share/$${TARGET}

INSTALLS += qml

OTHER_FILES += $$files(rpm/*)
# include(sailjail/sailjail.pri)
