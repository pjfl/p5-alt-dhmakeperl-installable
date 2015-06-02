use strict;
use warnings;

use Module::Build::WithXSpp;

sub testing { $ENV{AUTOMATED_TESTING} || $ENV{PERL_CPAN_REPORTER_CONFIG}
                                      || $ENV{PERL5_CPANPLUS_IS_VERSION} }
sub whimper { print {*STDOUT} $_[ 0 ]."\n"; exit 0 }

my $perl_ver = ##{ $meta2{prereqs}->{runtime}->{requires}->{perl} ##};
my $name     = '##{ $zilla->name ##}'; $name =~ s{ - }{::}gmx;
my $prereqs  = {
##{ $plugin->get_prereqs( 1 ) ##}
};

if ($] < $perl_ver) {
   # Not interested in reports below min perl ver or unsupported platforms
   testing or whimper "Minimum required Perl version is ${perl_ver}";
   $prereqs->{build_requires} = { %{ $prereqs->{configure_requires} } };
   $prereqs->{build_requires}->{ 'Test::Requires' } = 0.06;
   delete $prereqs->{requires};
}

Module::Build::WithXSpp->subclass( code => do { local $/; <DATA> } )->new(
   'extra_linker_flags' => [ '-lapt-pkg' ],
   'module_name' => $name,
   'notes' => { min_perl_version => $perl_ver, testing => testing },
   %{ $prereqs },
##{ $plugin->get_default('share_dir') ##}
)->create_build_script;

exit 0;

__DATA__

sub ACTION_generate_main_xs {
   return 1;
}

sub _find_share_dir_files {
   my $self = shift; my $share_dir = $self->share_dir or return; my @file_map;

   if ($share_dir->{dist}) {
      push @file_map, $self->_share_dir_map
         ( 'dist/DhMakePerl', $share_dir->{dist} );
   }

   if ($share_dir->{module}) {
      for my $mod (keys %{ $share_dir->{module} }) {
         (my $altmod = $mod) =~ s{::}{-}g;

         push @file_map, $self->_share_dir_map
            ( "module/${altmod}", $share_dir->{module}{ $mod } );
      }
   }

   return { @file_map };
}

sub _infer_xs_spec {
   my $self = shift; my $spec = $self->SUPER::_infer_xs_spec( @_ );

   my $file_base = $spec->{base_name};

   $spec->{archdir} = File::Spec->catdir
      ( $self->blib, 'arch', 'auto', $file_base );
   $spec->{bs_file} = File::Spec->catfile
      ( $spec->{archdir}, "${file_base}.bs" );
   $spec->{lib_file} = File::Spec->catdir
      ( $spec->{archdir}, "${file_base}.".$self->{config}->get( 'dlext' ) );

   return $spec;
}
