use t::boilerplate;

use Test::More;
use Test::Exception;
use Test::Differences;

use_ok 'Debian::Control';
use_ok 'Debian::Control::Stanza::Source';

my $s;

lives_ok { $s = Debian::Control::Stanza::Source->new } 'Source constructs';
lives_ok { $s->Source( 'foo' ) } 'Source set';

my $b;

lives_ok { $b = Debian::Control::Stanza::Binary->new } 'Binary constructs';
lives_ok { $b->Package('foo') } 'Package set';
lives_ok { $b->Depends('foo, bar (>= 5)') } 'Depends set';
is ref $b->Depends, 'Debian::Dependencies', 'Depends is an object';
is $b->Depends . q(), 'foo, bar (>= 5)', 'Depends stringifies to the same';
lives_ok { $b = Debian::Control::Stanza::Source->new( {
   'Build-Depends' => 'perl',
} ) } 'Build-Depens is supported as a field in new()';
ok( $b->Build_Depends eq 'perl', 'Value is in Build_Depends' );

my $control = <<'EOF';
Source: libtest-compile-perl
Section: perl
Priority: optional
Maintainer: Debian Perl Group <pkg-perl-maintainers@lists.alioth.debian.org>
Uploaders: Damyan Ivanov <dmn@debian.org>,
 Gregor Herrmann <gregoa@debian.org>,
 Gunnar Wolf <gwolf@debian.org>
Build-Depends: debhelper (>= 7),
 libmodule-build-perl,
 libtest-simple-perl
Build-Depends-Indep: libtest-pod-coverage-perl,
 libtest-pod-perl,
 libuniversal-require-perl,
 perl
Standards-Version: 3.8.3
Vcs-Browser: http://svn.debian.org/viewsvn/pkg-perl/trunk/libtest-compile-perl/
Vcs-Svn: svn://svn.debian.org/pkg-perl/trunk/libtest-compile-perl/
Homepage: https://metacpan.org/release/Test-Compile

Package: libtest-compile-perl
Architecture: all
Depends: ${misc:Depends}, ${perl:Depends},
 libuniversal-require-perl
Description: check whether Perl module files compile correctly
 Test::Compile can be used in module test suites to verify that everything
 compiles correctly. This description is artifitially prolonged, in order to be
 able to use some commas and test whether they wrap.
 .
 This module provides a few useful functions for manipulating module names. Its
 main aim is to centralise some of the functions commonly used by modules that
 manipulate other modules in some way, like converting module names to relative
 paths.
 .
 This description was automagically extracted from the module by dh-make-perl.
EOF

my $c;

lives_ok { $c = Debian::Control->new } 'Debian::Control constructs';

lives_ok { $c->read(\$control) } 'Parses a real control file';

is ref $c->source->Build_Depends_Indep, 'Debian::Dependencies',
   'Parsed source B-D-I is a Debian::Dependencies object';
is $c->source->Build_Depends_Indep,
   'libtest-pod-coverage-perl, libtest-pod-perl, libuniversal-require-perl, perl',
   'Parsed B-D-I as expected';

my $written = q();

lives_ok { $c->write(\$written) } 'Control writes can write to a scalar ref';
eq_or_diff( $written, $control, 'Control writes what it have read' );

use_ok 'Debian::Control::FromCPAN';

$c = Debian::Control::FromCPAN->new; $c->read( \$control );

my $bin = $c->binary->{ 'libtest-compile-perl' };

$bin->Depends->add( 'perl-modules' ); $c->prune_perl_deps;

is $bin->Depends . q(),
   '${misc:Depends}, ${perl:Depends}, libuniversal-require-perl',
   'Depends defaults';

# Test pruning dependency on perl version found in oldstable
$bin->Depends->add( 'perl (>= 5.8.8)' ); $c->prune_perl_deps;

is $bin->Depends . q(),
   '${misc:Depends}, ${perl:Depends}, libuniversal-require-perl',
   'Prune depends';

# Same thing, with B-D
$c->source->Build_Depends_Indep->add('perl (>= 5.8.8)'); $c->prune_perl_deps;

is $c->source->Build_Depends_Indep . q(),
   'libtest-pod-coverage-perl, libtest-pod-perl, libuniversal-require-perl, perl',
   'Prune build depends';

# Test wrapping
$b = Debian::Control::Stanza::Binary->new( {
   Package => "foo",
   Depends => "libfoo-perl (>= 0.44839848), libbar-perl, libbaz-perl (>= 4.59454345345485), libtreshchotka-moo (>= 5.6), libmoo-more-java (>= 9.6544)",
}, );

is "$b", <<EOF, 'Stanza Binary';
Package: foo
Depends: libfoo-perl (>= 0.44839848),
 libbar-perl,
 libbaz-perl (>= 4.59454345345485),
 libtreshchotka-moo (>= 5.6),
 libmoo-more-java (>= 9.6544)
EOF

done_testing;
