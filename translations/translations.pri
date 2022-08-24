TEMPLATE = aux
QMAKE_EXTRA_TARGETS += trans_release
INSTALLS += trans_release

trans_release.commands = lrelease -removeidentical $$_PRO_FILE_
trans_release.path = /usr/share/$${TARGET}/translations
trans_release.files = translations/*.qm

