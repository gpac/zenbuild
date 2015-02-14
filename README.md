# ZenBuild

ZenBuild is a one-shot component-level build-system, aimed at easing the build of free software projects.
It also aims at making cross-building seamless.

Syntax
------

The general syntax is:
```
$ ./zenbuild.sh <workingDirectory> <packageName> <targetArchitecture>
```

Example command:
```
$ ./zenbuild.sh /tmp/myWorkDirectory libav x86_64-w64-mingw32
```

Environment variables
---------------------

The environment variable MAKE is influential, you can achieve parallel builds this way:
```
$ MAKE='make -j8' ./zenbuild.sh /tmp/myWorkDirectory libav x86_64-w64-mingw32
```

If your environment variable PATH also contains other Unix-like environments such as Cygwin, you may want to restrict the environment PATH this way:
```
$ PATH='/mingw64/bin:/mingw32/bin:/usr/local/bin:/usr/bin:/opt/bin' ./zenbuild.sh /tmp/myWorkDirectory libav x86_64-w64-mingw32
```

Create custom script build
--------------------------

You can also create a standalone build script for a particular package (and
its dependencies) to integrate in your project:
```
$ ./make-extra.sh libav > build_libav.sh
```

You can now integrate build_libav.sh in your project, and invoke it this way:
```
$ ./build_libav.sh <targetArchitecture>
```

Authors
-------

- Sebastien Alaiwan <sebastien.alaiwan@gmail.com>
- Romain Bouqueau <romain.bouqueau.pro@gmail.com>

Contributors
------------

- badr-badri ( https://github.com/badr-badri )

