#!/bin/sh

printf "This script is intended for building on-device only.\nUse the usual '(auto|c|q)make' build systems if using SDK, OBS etc.\n\n"

rm -rf icons/z?.?* icons/??x?? icons/???x??? icons/????x????
specify -Nns rpm/*yaml || exit 1
printf linting...
find qml/ -type f -name "*.qml" -exec qmllint {} +
printf building...
rpmbuild -bb --build-in-place rpm/*.spec > build.log 2>&1
printf "exit: $?\n"
grep ^Wrote build.log

