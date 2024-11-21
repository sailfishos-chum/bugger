TEMPLATE = aux

QMAKE_EXTRA_TARGETS += svg appicon
#INSTALLS += svg appicon
INSTALLS += appicon

appicon.sizes = \
    86 \
    108 \
    128 \
    172 \
    256 \
    512 \
    1024

for(iconsize, appicon.sizes) {
    profile = $${iconsize}x$${iconsize}
    system(mkdir -p $${PWD}/icons/$${profile})

    appicon.commands += /usr/bin/sailfish_svg2png \
        -z 1.0 -s 1 1 1 1 1 1 $${iconsize} \
        $${PWD}/svgs \
        $${PWD}/icons/$${profile}/apps ;

    appicon.files += $${PWD}/icons/$${profile}
}
appicon.commands += true
appicon.path = $$PREFIX/share/icons/hicolor/

# also install SVG:
svg.path = $$PREFIX/share/icons/hicolor/scalable/apps
svg.files = $$PWD/svgs/*.svg
