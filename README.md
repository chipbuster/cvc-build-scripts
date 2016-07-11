# CVC Build Scripts

These scripts are designed to test CVC builds from the
[CVC SVN repository](https://svn.ices.utexas.edu/repos/cvc/) by checking
out the code and building it on various ICES machines. These scripts are
intended to be run from a crontab, though they can probably be manually
triggered.

#### Quick Start

To simply test established builds, follow these instructions. To write
scripts for new projects and systems, see "Writing new configurations".

First, edit the `configs.sh` file. Fill in the approriate hostname under
`I_AM` (make sure the a file of the same name exists under SYS_configs), 
place the names of the projects you want to build into the
`BUILD_TARGETS` array, and place the email(s) of the primary point(s)-of-contact
under `GUARDIANS`.

Go to the directory where the scripts were placed and run the
`run_build_test.sh` script to test the build. Note that the final entry in the
path to the scripts CANNOT be a symlink: if you place the script at
`/x/y/z/derp`, then strange things may happen if `derp` is a softlink.

#### Project Overview

The build system is driven by the `run\_build\_tests.sh` script in the
top-level directory which takes its configs from `configs.sh`. It reads
the `I_AM` variable and looks for that script in `SYS_configs` (e.g. if
`I\_AM=system32`, it attempts to read `SYS\_configs/system32`). 

For each project in the `BUILD\_TARGETS` array, the build system reads 
that project's `PROJECT_configs` file, sets up an appropriate environment
(removing old build directories, making new ones, and setting envars). It
then runs the `build_project` function in the project config.

If any of the builds fails once, it is restarted. If the build fails twice,
it triggers error-handling functions in `utils.sh`, which currently only
sends an email.

#### Writing new configurations

To write a new host configuration, copy one of the skeletons in the
`SYS_configs` directory that corresponds to your OS. Then set the four
variables listed as mandatory in the Host Settings section of this README.

Note that if you do not set NPES, the script will attempt to default to
the number of logical cores in the system. If it cannot detect this, it
will default to 1.

Also be aware that if the OS does not have a native QT install (e.g. OS
X), you must provide `QMAKE_EXECUTABLE` and `$QT_GH_FILE`. 

To write a new project configuration, you need to provide the components
listed in the Project Settings section of this README. A few gotchas for
the project settings:

*  Using undefined variables will crash the build. See the section on "Undefined Variables" for advice on sorting this out.
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
host identifier, which is used to figure out which host settings to use. There
should be a corresponding file in the SYS_configs directory.

`BUILD_TARGETS` is a list of targets to be built. For each entry in `BUILD_TARGETS`, a corresponding `.sh` should exist in the PROJECT_configs
directory.

`GUARDIANS` is a list of email addresses to contact if nobody else can be reached. 
By default, the script attempts to contact people who have committed in the last
2 days. If this is not possible (e.g. because a commit to an external dependency
broke the build, so nobody shows up in the SVN log), the project will notify 
anyone in `GUARDIANS`.

###### Host Settings

Host configurations are things like paths to the scratch directory and any
modules that need to be loaded on the local system. There are three skeleton
files (sl6.sh, c7.sh, and OSX.sh) that can be used to create hostfiles for
specific machines.

Each host settings file **must** export at least the following variables:

* `BUILD_OS`: A string identifying the operating system the build is on. For
ICES machines, this should be one of `SciLinux6` (Scientific Linux),
`CentOS7` (CentOS), or `OSX`.
* `BUILD_HOST`: A string identifying the system that the build takes place on. 
It is also how the system identifies itself in error messages, so use something specific and understood by everyone! Hostnames are a good choice.
* `HOST_MODLIST`: An array of modules that need to be loaded for most projects
to build (this includes at least the os modules, gcc, and cmake). These
 modules will be loaded when the main build script is first called and will
 remain loaded while all build tests are run. If no modules need to be loaded, simply make an empty list.
* `WORK_DIR`: A directory where code checkouts and build directories can be made.
This directory should be user-writeable and local (i.e. **not** NFS or SSHFS)

In addition, the host files may optionally export the following additional variables:

* `NPES`: The number of processors available for build on this computer. If not
  set, the build scripts will default to the logical cores if that count can be
  obtained, and 1 otherwise. You should usually set this number to the number of
  cores the machine has, else the builds may take several hours.
* Other environmental variables that may be necessary, e.g. `FC`, `CC`, and `CXX` on
  OS X w/ MacPorts, or `QT_SELECT` on Arch Linux. Make sure these are exported
  by either placing `export` in front of the definition or by placing
  `export VARNAME` further down in the file.

###### Project Settings

Project configurations are things like the SVN repository, needed libraries,
and build commands. Any of the existing configs should serve as examples.

Each project settings file **must** export at least the following variables:

* `PROJ_NAME`: A string identifying the project. This will be used to report
   errors and is also given to directories/files used in the build.
* `SVN_URL`: The URL used to fetch the source code (using `svn checkout`)

Optionally, a project may also export the following:

* `PROJ_MODLIST`: An array of modules needed to build the program. These will
  be loaded prior to compilation and unloaded afterwards, to avoid contaminating
  the environment for subsequent builds. These modules should **not**
  include cmake, gcc, or the OS module.
* Other environmental variables necessary to the build. These should be `unset`
  at the conclusion of the build to avoid contaminating the build environment.

Each project should also export a function named `build_project()` that will
run the necessary steps to build the software. This function can expect that
all of the host modules will be loaded, and that there will be a fresh copy
of the project at `$SRC_DIR`, that it will be in the directory `$BUILD_DIR`, and
that there will be a defined `$LOG_FILE`. There are several examples of build files
in the PROJECT_configs directory.

If **any** step of this function fails, the entire build is aborted. Keep this in mind as you write the function: don't put in something that returns an error result, because your entire build will be considered failed. If you have a function that returns non-zero as a part of regular operation (e.g. diff), then use the following idiom:

    function_that_does_not_exit_zero args || true

This will allow the build to continue.

You should make multiple project scripts for each build type
(e.g. if you want to build something in debug + release modes, you should make
  proj\_debug.sh and proj\_release.sh with appropriate project names.)

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

Make sure you do this in all of your project configuration functions: if you don't, the build will fail and someone will get a spurious error message!

#### Error Handling

First, and most importantly, the build script traps on any errors in the `build_project()` function. This means if there's any step in the function that fails, the entire build is considered to be in error.

If a build errors, the script will first attempt to restart the build. Sometimes the script fails for funky reasons (e.g. svn failure), so we attempt a second build to be sure.

If the second attempt also errors, a few things happen:

* Dump info is generated (strictly, this happens whether the build fails or 
	  not). This includes hostname, host OS, build time, modules, processor count,
	  the output of `svn info`, and the environment (captured with `printenv`). This
	  information is placed alongside the build output to help with diagnostics.
	  
* The logfile is copied to the workspace on `neuron`, accessible through `/net/neuron` on most ICES machines. This allows further analysis of the build.
	
* A list of all users that have committed to the repository in the past two days
	  is generated. Due to restrictions of the `svn log` command, this does *not*
	  include external projects, like third-party libraries.
	  
* The users who have committed in the last two days are given an email telling
	  them to check their builds. If no such users can be found, the emails in
	  `GUARDIANS` are contacted instead.
	  
These functions can be found in the `utils.sh` script.
