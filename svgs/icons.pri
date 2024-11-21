#
# we use upstream config for the Theme icons
# and custom for appicon.
#
# mkspecs/features/sailfish-svg2png.prf makes assumptions about file paths and locations so we must use
# this setup
#
# Configures svg to png
THEMENAME=sailfish-default
CONFIG += sailfish-svg2png

# for the app icon:
include(appicon/appicon.pri)
