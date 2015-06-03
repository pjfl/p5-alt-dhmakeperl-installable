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

- `gettext`
- `libapt-pkg-dev`

# Incompatibilities

The hard coded share directory path was replaced with a call to
[File::ShareDir](https://metacpan.org/pod/File::ShareDir)

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
