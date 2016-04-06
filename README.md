# CVC Build Scripts

These scripts are designed to test CVC builds from the
[CVC SVN repository](https://svn.ices.utexas.edu/repos/cvc/trunk/) by checking
out the code and building it on various ICES machines. These scripts are
intended to be run from a crontab, though they can probably be manually
triggered.

#### Quick Start



#### Project vs Host settings

There are two aspects to building a project: the project itself and the host.

###### Host Settings

Host configurations are things like paths to the scratch directory and any
modules that need to be loaded on the local system. There are three skeleton
files (sl6.sh, c7.sh, and osx.sh) that can be used to create hostfiles for
specific machines.

Each host settings file should export at least the following variables:

* `BUILD_OS`: A string identifying the operating system the build is on
* `HOST_MODLIST`: An array of modules that need to be    loaded for most projects
to build (this includes things like core modules, gcc, and cmake). These
 modules will be loaded when the main build script is first called and will
 remain loaded while all build tests are run.
* `WORK_DIR`: A directory where code checkouts and build directories can be made.
This directory should be user-writeable and local (i.e. **not** NFS or SSHFS)

In addition, the host files may optionally export the following additional variables:

* `BUILD_HOST`: A string identifying the system that the build takes place on
  (for example, a hostname)
* `MAIL_ERR_TO`: This will cause the script to send any error logs to the listed
   email address. May send multiple emails if combined with crontab mail--be careful!
* `NPES`: The number of processors available for build on this computer.
* Other environmental variables that may be necessary, e.g. `FC`, `CC`, and `CXX` on
  OS X w/ MacPorts, or `QT_SELECT` on Arch Linux.

###### Project Settings

Project configurations are things like the SVN repository, needed libraries,
and build commands. Any of the existing configs should serve as examples.

Each project settings file should export at least the following variables:

* `PROJ_NAME`: A string identifying the project. This will be used to report
   errors and is also the name given to directories/files
* `SVN_URL`: The URL used to fetch the source code (using `svn clone`)

Optionally, a project may also export the following:

* `PROJ_MODLIST`: An array of modules needed to build the program. These will
  be loaded prior to compilation and unloaded afterwards, to avoid contaminating
  the environment for subsequent builds.
* `VAR_NEEDS`: A list of environmental variables needed to execute the build.
* Other environmental variables necessary to the build. These should be `unset`
  at the conclusion of the build to avoid contaminating the build environment.

Each project should also export a function named `build_project()` that will
run the necessary steps to build the software. This function can expect that
all of the host modules will be loaded, and that there will be a fresh copy of the project at `$WORK_DIR/$PROJ_NAME`. It will need to load all of its build modules,
run the build system, and then unload its modules and clear any environmental variables
it set. It may optionally depend on `BUILD_OS` being set.

Note: you should make multiple project scripts for each build type (e.g. if you want to build something in debug + release modes, you should make proj_debug.sh and proj_release.sh with appropriate project names.)
