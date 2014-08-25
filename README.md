ZenBuild is a component-level build-system, aimed at easing the build of free software projets.
It also aims at making cross-building seamless.

Authors:
- Sebastien Alaiwan <sebastien.alaiwan@gmail.com>
- Romain Bouqueau <romain.bouqueau.pro@gmail.com>

The general syntax is:

./zenbuild.sh <workingDirectory> <targetArchitecture> <packageName>

Example command:

./zenbuild.sh /tmp/myWorkDirectory x86_64-w64-mingw32 libav

The environment variable MAKE is influential, you can achieve parallel builds this way:

MAKE='make -j8' ./zenbuild.sh /tmp/myWorkDirectory x86_64-w64-mingw32 libav

