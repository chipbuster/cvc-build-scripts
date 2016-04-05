# CVC Build Scripts

These scripts are designed to test CVC builds from the
[CVC SVN repository](https://svn.ices.utexas.edu/repos/cvc/trunk/) by checking
out the code and building it on various ICES machines. These scripts are
intended to be run from a crontab, though they can probably be manually
triggered.



#### Project vs Host settings

There are two aspects to building a project: the project itself and the host.

Project configurations are things like the SVN repository, needed libraries,
and build commands.

Host configurations are things like paths to the scratch directory and any
modules that need to be loaded on the local system. Also of potential interest
are any extra environmental variables that need to be set (e.g. choice of
`FC`,`CC`,and `CXX` on OS X, or `QT_SELECT` on ArchLinux).
