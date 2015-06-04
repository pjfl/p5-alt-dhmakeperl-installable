<div>
    <a href="https://travis-ci.org/pjfl/p5-alt-dhmakeperl-installable"><img src="https://travis-ci.org/pjfl/p5-alt-dhmakeperl-installable.svg?branch=master" alt="Travis CI Badge"></a>
</div>

# Name

Alt::DhMakePerl::installable - Create Debian source package from CPAN dist

# Synopsis

    use DhMakePerl;

    DhMakePerl->run;

# Description

Clone of [DhMakePerl](https://metacpan.org/pod/DhMakePerl) but installable. It includes the packages missing from
CPAN that prevent the original from being installed

Addresses the issue in RT#64378

# Configuration and Environment

Defines no attributes

# Subroutines/Methods

None

# Diagnostics

None

# Dependencies

Requires the following native packages to be installed

- `libapt-pkg-dev`

# Incompatibilities

The hard coded share directory path (in the original) was replaced with a call
to [File::ShareDir](https://metacpan.org/pod/File::ShareDir)

This distribution will only install on the Linux operating system if the
dependent native packages are installed

# Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Alt-DhMakePerl-installable.
Patches are welcome

# Acknowledgements

Larry Wall - For the Perl programming language

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2015 Peter Flanigan. All rights reserved

GNU GENERAL PUBLIC LICENSE Version 2
