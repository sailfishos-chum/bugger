OTHER_FILES += $${TARGET}-gather-logs.target\
               $${TARGET}-gather-logs.service\
               $${TARGET}-gather-logs_hybris.service \
               $${TARGET}-gather-logs_android.service \
               $${TARGET}-gather-logs-plugin@.service

INSTALLS += sdservice

sdservice.files = $$PWD/$${TARGET}-gather-logs.target \
                  $$PWD/$${TARGET}-gather-logs.service \
                  $$PWD/$${TARGET}-gather-logs_android.service \
                  $$PWD/$${TARGET}-gather-logs_hybris.service \
                  $$PWD/$${TARGET}-gather-logs-plugin@.service

sdservice.path = $$INSTALL_ROOT/usr/lib/systemd/user

