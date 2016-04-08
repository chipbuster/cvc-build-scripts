# CVC Build Scripts

These scripts are designed to test CVC builds from the
[CVC SVN repository](https://svn.ices.utexas.edu/repos/cvc/trunk/) by checking
out the code and building it on various ICES machines. These scripts are
intended to be run from a crontab, though they can probably be manually
triggered.

#### Quick Start

To simply test established builds, follow these instructions. To write
scripts for new projects and systems, see "Writing new configurations".

First, edit the `configs.sh` file. Fill in the approriate hostname under
`I_AM`, place the names of the projects you want to build into the
`BUILD_TARGETS` array, and place emails under `GUARDIANS`

Then from this directory, run

    ./install.sh /path/to/installation

Go to the directory where the scripts were installed and run the
`run_build_test.sh` script to test the build.

#### Writing new configurations

To write a new host configuration, copy one of the skeletons in the
`SYS_configs` directory that corresponds to your OS. Then set the four
variables listed as mandatory in the Host Settings section of this README.

Note that if you do not set NPES, the script will attempt to default to
the number of logical cores in the system. If it cannot detect this, it
will default to 1.

Also be aware that if the OS does not have a native QT install (OS X), you
must provide `QMAKE_EXECUTABLE` and `$QT_GH_FILE`.

To write a new project configuration, you need to provide the components
listed in the Project Settings section of this README. A few gotchas for
the project settings:

*  Using undefined variables will crash the build--this includes things like
`LIBRARY_PATH` (see the Undefined Variables section for details on how to
  avoid this)
* You must use `SRC_DIR`, `BUILD_DIR`, and `LOG_FILE` to access the source
folder, build folder, and log file respectively. There are no guarantees
that these varibles will not be changed in the future.
* If `QMAKE_EXECUTABLE` and `$QT_GH_FILE` are set, QT may not exist in the
`PATH`. This will confuse cmake if not accounted for (see the texmol build
script for an example of how to deal with this).
* YOU CANNOT USE UNDEFINED VARIABLES IN THE BUILD FUNCTION.

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
files (sl6.sh, c7.sh, and OSX.sh) that can be used to create hostfiles for
specific machines.

Each host settings file **must** export at least the following variables:

* `BUILD_OS`: A string identifying the operating system the build is on. For
ICES machines, this should be one of `SciLinux6` (Scientific Linux),
`CentOS7` (CentOS), or `OSX`.
* `BUILD_HOST`: A string identifying the system that the build takes place on
  (for example, a hostname)
* `HOST_MODLIST`: An array of modules that need to be loaded for most projects
to build (this includes things like core modules, gcc, and cmake). These
 modules will be loaded when the main build script is first called and will
 remain loaded while all build tests are run. If no modules need to be loaded, simply make an empty list.
* `WORK_DIR`: A directory where code checkouts and build directories can be made.
This directory should be user-writeable and local (i.e. **not** NFS or SSHFS)

In addition, the host files may optionally export the following additional variables:

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

Each project settings file **must** export at least the following variables:

* `PROJ_NAME`: A string identifying the project. This will be used to report
   errors and is also the name given to directories/files
* `SVN_URL`: The URL used to fetch the source code (using `svn clone`)

Optionally, a project may also export the following:

* `PROJ_MODLIST`: An array of modules needed to build the program. These will
  be loaded prior to compilation and unloaded afterwards, to avoid contaminating
  the environment for subsequent builds.
* Other environmental variables necessary to the build. These should be `unset`
  at the conclusion of the build to avoid contaminating the build environment.

Each project should also export a function named `build_project()` that will
run the necessary steps to build the software. This function can expect that
all of the host modules will be loaded, and that there will be a fresh copy
of the project at `$SRC_DIR`, that it will be in the directory `$BUILD_DIR`, and
that there will be a defined `$LOG_FILE`.

You should make multiple project scripts for each build type
(e.g. if you want to build something in debug + release modes, you should make
  proj_debug.sh and proj_release.sh with appropriate project names.)

#### Undefined Variables

Note that some parts of the build scripts (most notably the `build_project`
functions) will fail if an undefined variable is used. This may be an issue if
you are attempting to append to an envar, e.g. the following will fail if
`LIBRARY_PATH` is not defined:

        LIBRARY_PATH = /my/path:$LIBRARY_PATH

To get around this issue, use parameter expansion:
`${VAR=""}` will expand to `$VAR` if it is defined and `""` otherwise. This
allows you to check for potentially undefined variables without tripping
the undefined var checker. The fix for the above is to use

        LIBRARY_PATH = /my/path:${LIBRARY_PATH=""}
