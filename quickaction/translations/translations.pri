qa_qm.input    = QA_TRANSLATIONS
qa_qm.output   = $$PWD/${QMAKE_FILE_BASE}.qm
qa_qm.commands = @echo "compiling ${QMAKE_FILE_NAME}"; \
                lrelease -removeidentical -idbased -silent ${QMAKE_FILE_NAME} -qm ${QMAKE_FILE_OUT}
qa_qm.CONFIG   = target_predeps no_link

QMAKE_EXTRA_COMPILERS += qa_qm

qa_translations.files = $$PWD/*.qm
qa_translations.path  = $$PREFIX/share/translations
qa_translations.CONFIG += no_check_exist

INSTALLS += qa_translations
