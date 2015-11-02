[![Build Status](https://travis-ci.org/gpac/zenbuild.svg?branch=master)](https://travis-ci.org/gpac/zenbuild)

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
$ ./zenbuild.sh /tmp/myWorkDirectory gpac x86_64-w64-mingw32
```

Package Names
-------------

You can use any name in the 'zen-*.sh' pattern. For example, if a ```zen-ffmpeg.sh``` file exists, you can invoke the ```ffmpeg``` package name.

Environment variables
---------------------

The environment variable MAKE is influential, you can achieve parallel builds this way:
```
$ MAKE='make -j8' ./zenbuild.sh /tmp/myWorkDirectory gpac x86_64-w64-mingw32
```

If your environment variable PATH also contains
 - other Unix-like environments such as Cygwin,
 - or spaces,
you may want to restrict the environment PATH this way:
```
$ PATH='/mingw64/bin:/mingw32/bin:/usr/local/bin:/usr/bin:/opt/bin' ./zenbuild.sh /tmp/myWorkDirectory gpac x86_64-w64-mingw32
```

MSys: Install Python2 for Windows, install it in a directory with no space, and make it first in the path:
```
$ PATH='/c/python27/:/mingw64/bin:/mingw32/bin:/usr/local/bin:/usr/bin:/opt/bin' ./zenbuild.sh /tmp/myWorkDirectory gpac x86_64-w64-mingw32
```

Create custom script build
--------------------------

You can also create a standalone build script for a particular package (and
its dependencies) to integrate in your project:
```
$ ./make-extra.sh gpac > build_gpac.sh
```

You can now integrate build_gpac.sh in your project, and invoke it this way:
```
$ ./build_gpac.sh <targetArchitecture>
```

Authors
-------

- Sebastien Alaiwan <sebastien.alaiwan@gmail.com>
- Romain Bouqueau <romain.bouqueau.pro@gmail.com>

Contributors
------------

- badr-badri ( https://github.com/badr-badri )
- Rodolphe Fouquet ( https://github.com/RodolpheFouquet )
