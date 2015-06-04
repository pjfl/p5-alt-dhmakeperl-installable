package t::boilerplate;

use strict;
use warnings;
use File::Spec::Functions qw( catdir updir );
use FindBin               qw( $Bin );
use lib               catdir( $Bin, updir, 'lib' ), catdir( $Bin, 'lib' );

use English qw( -no_match_vars );
use Test::More;
use Test::Requires { version => 0.88 };
use Module::Build;
use Sys::Hostname;

my $builder; my $notes; my $perl_ver;

BEGIN {
   $builder  = eval { Module::Build->current };
   $notes    = $builder ? $builder->notes : {};
   $perl_ver = $notes->{min_perl_version} || 5.008;
   $notes->{testing} and lc $OSNAME ne 'linux'
                     and plan skip_all => 'OS unsupported';
   $notes->{testing} and not $notes->{have_required_libs}
                     and plan skip_all => 'Required libs not found';
}

use Test::Requires "${perl_ver}";

sub import {
   strict->import;
   $] < 5.008 ? warnings->import : warnings->import( NONFATAL => 'all' );
   return;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
# vim: expandtab shiftwidth=3:
