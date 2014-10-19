ZenBuild is a one-shot component-level build-system, aimed at easing the build of free software projets.
It also aims at making cross-building seamless.

Authors:
- Sebastien Alaiwan <sebastien.alaiwan@gmail.com>
- Romain Bouqueau <romain.bouqueau.pro@gmail.com>

The general syntax is:
$ ./zenbuild.sh <workingDirectory> <targetArchitecture> <packageName>

Example command:
$ ./zenbuild.sh /tmp/myWorkDirectory x86_64-w64-mingw32 libav

The environment variable MAKE is influential, you can achieve parallel builds this way:
$ MAKE='make -j8' ./zenbuild.sh /tmp/myWorkDirectory x86_64-w64-mingw32 libav

If your environment variable PATH also contains other Unix-like environments such as Cygwin, you may want to restrict the environment PATH this way:
PATH='/mingw64/bin:/mingw32/bin:/usr/local/bin:/usr/bin:/opt/bin' ./zenbuild.sh /tmp/myWorkDirectory x86_64-w64-mingw32 libav

You can also create a standalone build script for a particular package (and
its dependencies) to integrate in your project:
$ ./make-extra.sh libav > build_libav.sh

You can now integrate build_libav.sh in your project, and invoke it this way:
$ ./build_libav.sh <targetArchitecture>
