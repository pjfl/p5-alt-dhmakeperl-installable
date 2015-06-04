use strict;
use warnings;

use Module::Build::WithXSpp;

my $testing  = sub { $ENV{AUTOMATED_TESTING}
                  || $ENV{PERL_CPAN_REPORTER_CONFIG}
                  || $ENV{PERL5_CPANPLUS_IS_VERSION} };
my $whimper  = sub { print {*STDOUT} $_[ 0 ]."\n"; exit 0 };
my $perl_ver = ##{ $meta2{prereqs}->{runtime}->{requires}->{perl} ##};
my $name     = '##{ $zilla->name ##}'; $name =~ s{ - }{::}gmx;
my $prereqs  = {
##{ $plugin->get_prereqs( 1 ) ##}
};
my $stop     = sub {
   $testing->() or $whimper->( $_[ 0 ] );
   $prereqs->{build_requires} = { %{ $prereqs->{configure_requires} } };
   $prereqs->{build_requires}->{ 'Test::Requires' } = 0.06;
   delete $prereqs->{requires};
};

# Not interested in reports on unsupported platforms
lc $^O ne 'linux' and $stop->( 'OS unsupported' );
# Not interested in reports below min perl ver
$] < $perl_ver    and $stop->( "Minimum required Perl version is ${perl_ver}" );

Module::Build::WithXSpp->subclass( code => do { local $/; <DATA> } )->new(
   'extra_linker_flags' => [ '-lapt-pkg' ],
   'module_name' => $name,
   'notes' => { min_perl_version => $perl_ver, testing => $testing->() },
   %{ $prereqs },
##{ $plugin->get_default('share_dir') ##}
)->create_build_script;

exit 0;

__DATA__

use ExtUtils::CChecker;

{  no warnings 'redefine';

   *ExtUtils::CChecker::compile = sub {
      my ($self, %args) = @_;

      $args{include_dirs} = [ map { defined $_ ? @{ $_ } : () }
                              $self->{include_dirs}, $args{include_dirs} ];
      $args{extra_compiler_flags} = [ map { defined $_ ? @{ $_ } : () }
                                      $self->{extra_compiler_flags},
                                      $args{extra_compiler_flags} ];
      $args{ 'C++' } = 1;

      $self->cbuilder->compile( %args );
   };
}

sub ACTION_code {
   my ($self, @args) = @_; my $cc = ExtUtils::CChecker->new;

   my $success = $cc->try_find_libs_for
      ( libs => [ 'apt-pkg' ] , source => <<'EOS' );
        #include <string>
        #include <vector>
        #include <apt-pkg/init.h>
        int main(int argc, char *argv[]) {
           return 0;
        }
EOS

   $self->notes( have_required_libs => $success );
   $success and return $self->SUPER::ACTION_code( @args );
   $self->notes( 'testing' ) and return 1;
   print {*STDOUT} "Required OS native packages missing; libapt-pkg-dev\n";
   exit 0;
}

sub ACTION_generate_main_xs {
   return 1;
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
