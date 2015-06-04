use strict;
use warnings;

use Module::Build::WithXSpp;

my $testing  = sub { $ENV{AUTOMATED_TESTING}
                  || $ENV{PERL_CPAN_REPORTER_CONFIG}
                  || $ENV{PERL5_CPANPLUS_IS_VERSION} };
my $whimper  = sub { print {*STDOUT} $_[ 0 ]."\n"; exit 0 };
my $perl_ver = 5.010001;
my $name     = 'Alt-DhMakePerl-installable'; $name =~ s{ - }{::}gmx;
my $prereqs  = {
  'build_requires' => {
    'ExtUtils::CChecker' => '0.10',
    'Module::Build' => '0.4004',
    'Module::Build::WithXSpp' => '0.14',
    'Test::Compile' => 'v1.2.1',
    'Test::Requires' => '0.06',
    'version' => '0.88'
  },
  'configure_requires' => {
    'ExtUtils::CChecker' => '0.10',
    'Module::Build' => '0.4004',
    'Module::Build::WithXSpp' => '0.14',
    'version' => '0.88'
  },
  'requires' => {
    'Array::Unique' => '0.08',
    'CPAN::Meta' => '2.142690',
    'Class::Accessor' => '0.34',
    'Email::Address' => '1.905',
    'Email::Date::Format' => '1.005',
    'File::ShareDir' => '1.102',
    'File::Which' => '1.09',
    'HTML::Parser' => '3.71',
    'HTML::Template' => '2.95',
    'IO::String' => '1.08',
    'LWP::UserAgent' => '6.06',
    'List::MoreUtils' => '0.33',
    'Module::Depends' => '0.16',
    'Parse::DebControl' => '2.005',
    'Software::License' => '0.103010',
    'Tie::IxHash' => '1.23',
    'WWW::Mechanize' => '1.73',
    'YAML' => '1.13',
    'perl' => '5.010001',
    'version' => '0.88'
  },
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

)->create_build_script;

exit 0;

__DATA__

use ExtUtils::CChecker;

sub ACTION_code {
   my ($self, @args) = @_; my $cc = ExtUtils::CChecker->new;

   my $success = $cc->try_find_libs_for
      ( libs => [ 'apt-pkg' ] , source => <<'EOS' );
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
