OTHER_FILES += $${TARGET}-gather-logs.service

INSTALLS += sdservice

sdservice.files = $$PWD/$${TARGET}-gather-logs.service
sdservice.path = $$INSTALL_ROOT/usr/lib/systemd/user

