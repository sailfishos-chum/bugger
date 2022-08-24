OTHER_FILES += \
    $$PWD/$${TARGET}.profile \
    $$PWD/$${TARGET}.local \

INSTALLS += sjprofile fjprofile

sjprofile.files = $$PWD/$${TARGET}.profile
sjprofile.path = $$INSTALL_ROOT/etc/sailjail/permissions

fjprofile.files = $$PWD/$${TARGET}.local
fjprofile.path = $$INSTALL_ROOT/etc/firejail

