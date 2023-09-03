OTHER_FILES += $${TARGET}-gather-logs.target\
               $${TARGET}-gather-logs.service\
               $${TARGET}-gather-logs_basic.service \
               $${TARGET}-gather-logs_hybris.service \
               $${TARGET}-gather-logs_android.service \
               $${TARGET}-gather-logs_update.service \
               $${TARGET}-gather-logs_jolla.service \
               $${TARGET}-gather-logs-plugin@.service \
               $${TARGET}-journalconf.service

INSTALLS += sdservice

sdservice.files = $$PWD/$${TARGET}-gather-logs.target \
               $$PWD/$${TARGET}-gather-logs.service \
               $$PWD/$${TARGET}-gather-logs_hybris.service \
               $$PWD/$${TARGET}-gather-logs_basic.service \
               $$PWD/$${TARGET}-gather-logs_android.service \
               $$PWD/$${TARGET}-gather-logs_update.service \
               $$PWD/$${TARGET}-gather-logs_jolla.service \
               $$PWD/$${TARGET}-gather-logs-plugin@.service

sdservice.path = $$INSTALL_ROOT/usr/lib/systemd/user

INSTALLS += jcservice
jcservice.files = $$PWD/$${TARGET}-journalconf.service
jcservice.path = $$INSTALL_ROOT/usr/lib/systemd/system

INSTALLS += journalconf
journalconf.path = $$INSTALL_ROOT/usr/share/$$TARGET
journalconf.files = $$PWD/99_bugger_full_debug.conf
