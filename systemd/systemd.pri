OTHER_FILES += $${TARGET}-gather-logs.target\
               $${TARGET}-gather-logs.service\
               $${TARGET}-gather-android-logs.service

INSTALLS += sdservice

sdservice.files = $$PWD/$${TARGET}-gather-logs.target \
                  $$PWD/$${TARGET}-gather-logs.service \
                  $$PWD/$${TARGET}-gather-android-logs.service
sdservice.path = $$INSTALL_ROOT/usr/lib/systemd/user

