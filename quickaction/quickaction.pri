
qa_settings.files = $$PWD/jolla-settings/entries/$${TARGET}.json
qa_settings.path = $$INSTALL_ROOT/usr/share/jolla-settings/entries/
INSTALLS += qa_settings

lupdate_only {
    SOURCES += $$PWD/strings.qml
}

QA_TRANSLATIONS += $$PWD/translations/$${TARGET}-quickactions-en.ts \
                   $$PWD/translations/$${TARGET}-quickactions-de.ts \
                   $$PWD/translations/$${TARGET}-quickactions-no.ts \
                   $$PWD/translations/$${TARGET}-quickactions-sv.ts

# for updating translations
QMAKE_EXTRA_TARGETS += qa_ts
qa_ts.commands = lupdate $$PWD/quickaction.pri

include(translations/translations.pri)


