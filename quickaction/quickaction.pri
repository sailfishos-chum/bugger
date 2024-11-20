
qa_action.files = $$PWD/lipstick/quickactions/$${TARGET}.conf
qa_action.path = $$INSTALL_ROOT/usr/share/lipstick/quickactions
INSTALLS += qa_action

qa_settings.files = $$PWD/jolla-settings/entries/$${TARGET}.json
qa_settings.path = $$INSTALL_ROOT/usr/share/jolla-settings/entries/
INSTALLS += qa_settings

