# CVC Build Scripts

These scripts are designed to test CVC builds from the
[CVC SVN repository](https://svn.ices.utexas.edu/repos/cvc/trunk/) by checking
out the code and building it on various ICES machines. These scripts are
intended to be run from a crontab, though they can probably be manually
triggered.

#### Quick Start



#### Installation



#### Settings Details

###### Config Settings

These are found in configs.sh and tell the build system what to do. `I_AM` is the
host identifier, which is used to figure out which host settings to use.

`BUILD_TARGETS` is a list of targets to be built. For each entry in `BUILD_TARGETS`,
a corresponding `.sh` should exist in PROJECT_configs.

`GUARDIANS` is a list of email addresses to contact if something breaks.

###### Host Settings

Host configurations are things like paths to the scratch directory and any
modules that need to be loaded on the local system. There are three skeleton
files (sl6.sh, c7.sh, and osx.sh) that can be used to create hostfiles for
specific machines.

Each host settings file should export at least the following variables:

* `BUILD_OS`: A string identifying the operating system the build is on. For
ICES machines, this should be one of `sl6` (Scientific Linux), `c7` (CentOS), or `osx`.
* `BUILD_HOST`: A string identifying the system that the build takes place on
  (for example, a hostname)
* `HOST_MODLIST`: An array of modules that need to be loaded for most projects
to build (this includes things like core modules, gcc, and cmake). These
 modules will be loaded when the main build script is first called and will
 remain loaded while all build tests are run. If no modules need to be loaded, simply make an empty list.
* `WORK_DIR`: A directory where code checkouts and build directories can be made.
This directory should be user-writeable and local (i.e. **not** NFS or SSHFS)

In addition, the host files may optionally export the following additional variables:

* `MAIL_ERR_TO`: This will cause the script to send any error logs to the listed
   email address. May send multiple emails if combined with crontab mail--be careful!
* `NPES`: The number of processors available for build on this computer. If not
  set, the build scripts will default to 1, which will be slooooooooowwwww. Note:
  you should set this to take advantage of hyperthreading for fastest builds.
* Other environmental variables that may be necessary, e.g. `FC`, `CC`, and `CXX` on
  OS X w/ MacPorts, or `QT_SELECT` on Arch Linux. Make sure these are exported
  by either placing `export` in front of the definition or by placing
  `export VARNAME` further down in the file.

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
all of the host modules will be loaded, and that there will be a fresh copy
of the project at `$SRC_DIR`, that it will be in the directory `$BUILD_DIR`, and
that there will be a defined `$LOG_FILE`.

Any other variables may not be defined, and this system is set to error if
undefined variables are used. To get around this issue, use parameter expansion:
`${VAR=""}` will expand to `$VAR` if it is defined and `""` otherwise. This
allows you to check for potentially undefined variables without tripping
the undefined var checker.

Note: you should make multiple project scripts for each build type
(e.g. if you want to build something in debug + release modes, you should make
  proj_debug.sh and proj_release.sh with appropriate project names.)
