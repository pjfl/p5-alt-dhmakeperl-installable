package Alt::DhMakePerl::installable;

use 5.010001;
use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 9 $ =~ /\d+/gmx );

1;

__END__

=pod

=encoding utf-8

=head1 Name

Alt::DhMakePerl::installable - Create Debian source package from CPAN dist

=head1 Synopsis

   use DhMakePerl;

   DhMakePerl->run;

=head1 Description

Clone of L<DhMakePerl> but installable. It includes the packages missing from
CPAN that prevent the original from being installed

Addresses the issue in RT#64378

=head1 Configuration and Environment

Defines no attributes

=head1 Subroutines/Methods

None

=head1 Diagnostics

None

=head1 Dependencies

Requires the following native packages to be installed

=over 3

=item C<libapt-pkg-dev>

=back

=head1 Incompatibilities

The hard coded share directory path was replaced with a call to
L<File::ShareDir>

=head1 Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Alt-DhMakePerl-installable.
Patches are welcome

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2015 Peter Flanigan. All rights reserved

GNU GENERAL PUBLIC LICENSE Version 2

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
# vim: expandtab shiftwidth=3:
