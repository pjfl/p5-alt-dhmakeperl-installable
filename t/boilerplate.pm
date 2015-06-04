package t::boilerplate;

use strict;
use warnings;
use File::Spec::Functions qw( catdir updir );
use FindBin               qw( $Bin );
use lib               catdir( $Bin, updir, 'lib' ), catdir( $Bin, 'lib' );

use Test::More;
use Test::Requires { version => 0.88 };
use English      qw( -no_match_vars  );
use Module::Build;
use Sys::Hostname;

my $builder; my $notes; my $perl_ver;

BEGIN {
   $builder  = eval { Module::Build->current };
   $notes    = $builder ? $builder->notes : {};
   $perl_ver = $notes->{min_perl_version} || 5.008;

   if ($notes->{testing}) {
      $Bin =~ m{ : .+ : }mx and plan skip_all => 'Two colons in $Bin path';
      lc $OSNAME ne 'linux' and plan skip_all => 'OS unsupported';
      $notes->{have_required_libs}
                             or plan skip_all => 'Required libs not found';
   }
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
