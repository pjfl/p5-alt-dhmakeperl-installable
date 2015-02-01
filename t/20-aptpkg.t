use t::boilerplate;

use Test::More;
use English qw( -no_match_vars );

use_ok 'AptPkg::Config';
use_ok 'AptPkg::Source';
use_ok 'AptPkg::Version';

use AptPkg::Config '$_config';
use AptPkg::System '$_system';

my $c = AptPkg::Config->new;

is $c->set( a => 42 ), 42, 'set';
is $c->get( 'a' ), 42, 'get';
is $c->get( 'not there', 'default' ), 'default', 'default';

$c->set( b => '/tmp/' ); $c->set( 'b::c' => 'foo' );

is $c->get_file( 'b::c' ), '/tmp/foo',  'get file';
is $c->get_dir( 'b::c' ),  '/tmp/foo/', 'get_dir';
is $c->get( 'b::c/f' ),    '/tmp/foo',  '/f suffix';
is $c->get( 'b::c/d' ),    '/tmp/foo/', '/d suffix';

$c->set( c => 'false' ); $c->set( d => 'yes' );

ok !$c->get_bool( 'c' ),       'get bool false';
ok $c->get_bool( 'd' ),        'get bool true';
ok $c->exists( 'c' ),          'exists';
ok !$c->exists( 'not there' ), 'not exists';

{
    local $SIG{__WARN__} = sub { die @_ };
    eval { $c->read_file( 't/config.conf' ) };
}

ok !$EVAL_ERROR, 'read file';
ok $c->get( 'e' ) eq 'e_val' && $c->get( 'e::f' ) eq 'f_val', 'file values';

my @r = $c->parse_cmdline
   ( [ ['q', 'qtest', 'qtest', 'int_level' ],
       ['r', 'rtest', 'rtest', 'int_level' ],
       ['s', 'stest', 'stest', 'int_level' ],
       ['t', 'ttest', 'ttest', 'has_arg'   ],
       ['o', 'otest', '',      'arb_item'  ], ],
     '-q', '-rr', '-s=3', '--ttest=t', '-ofoo=bar', 'cmd' );

ok !($c->get( 'qtest' ) != 1 || $c->get( 'rtest' ) != 2 ||
     $c->get( 'stest' ) != 3 || $c->get( 'ttest' ) ne 't' ||
     $c->get( 'foo' ) ne 'bar' || "@r" ne 'cmd'), 'parse cmdline';
is $c->Find( 'a' ), 42, 'XS methods';

$c = $AptPkg::Config::_config;

ok $c->init, 'init';
is $c->get_dir( 'Dir::Etc' ), '/etc/apt/', 'config get dir';

$c = AptPkg::Config->new; $c->{a} = 42; $c->{b} = 'foo';

ok $c->{a} == 42 && $c->{b} eq 'foo', 'hash access';

@r = keys %{ $c };

is "@r", 'a b', 'hash keys';

@r = values %{ $c };

is "@r", '42 foo', 'hash values';

@r = $c->keys;

is "@r", 'a b', 'explicit iterator 1';

@r = (); for (my $i = $c->keys; my $k = $i->next; ) { push @r, $k }

is "@r", 'a b', 'explicit iterator 2';

ok $_config->init && ($_system = $_config->system), 'config and system';

my $type = 'dpkg'; -f '/etc/redhat-release' and $type = 'rpm';

like $_system->label, qr{ $type }mx, 'system type';

my $v = $_system->versioning;

ok $v, 'system versioning';

ok $v->compare( '1.0', '1.1' ) < 0, 'version compare 1';
ok $v->compare( '1.1', '1.0' ) > 0, 'version compare 2';
ok $v->compare( '1.1', '1.1' ) == 0, 'version compare 3';
ok $v->compare( '1.2-1', '1.2-2' ) < 0, 'version compare 4';
ok $v->compare( '1.2.3', '1.20.2') < 0, 'version compare 5';
ok $v->compare( '1.2.3', '1:1.0' ) < 0, 'version compare 6';

ok $v->check_dep( '1', '<<', '2' ), 'version check dep 1';
ok $v->check_dep( '1', '<=', '2' ), 'version check dep 2';
ok $v->check_dep( '2', '<=', '2' ), 'version check dep 3';
ok $v->check_dep( '1', '=',  '1' ), 'version check dep 4';
ok $v->check_dep( '2', '>=', '2' ), 'version check dep 5';
ok $v->check_dep( '2', '>=', '1' ), 'version check dep 6';
ok $v->check_dep( '2', '>>', '1' ), 'version check dep 7';

ok !$v->check_dep( '1', '>>', '2' ), 'version check dep 8';
ok !$v->check_dep( '1', '>=', '2' ), 'version check dep 9';
ok !$v->check_dep( '1', '=',  '2' ), 'version check dep 10';
ok !$v->check_dep( '2', '<=', '1' ), 'version check dep 11';
ok !$v->check_dep( '2', '<<', '1' ), 'version check dep 12';

is $v->upstream( "1:6.12-3-1.2" ), '6.12-3', 'version upstream';

$_config->init;
$_config->read_file( 't/cache/etc/apt.conf' );
$_config->{quiet} = 0;

my $src = AptPkg::Source->new;

ok $src, 'new source';

my $sa = $src->{a};

is @{ $sa }, 1, 'source a count';

$sa = $sa->[ 0 ];

is $sa->{Package}, 'a', 'source a package';
is $sa->{Section}, 'test', 'source a section';
is $sa->{Version}, '0.1', 'source a version';
ok $sa->{Binaries} && (ref $sa->{Binaries} eq 'ARRAY')
   && ("@{$sa->{Binaries}}" eq 'a'), 'source a binaries';

my $bd = $sa->{BuildDepends}{'Build-Depends'};

is $bd->[0][0], 'b', 'build depends';
is $bd->[0][1], '>=', 'build depends comparison';
is $bd->[0][2], '0.2-42', 'build compares version';

my ($dsc) = grep { $_->{Type} eq 'dsc' } @{ $sa->{Files} };

like $dsc->{ArchiveURI}, qr{ pool/main/a/a/a_0\.1\.dsc \z}mx, 'dsc archive uri';
is   $dsc->{MD5Hash}, '8202ae7d918948c192bdc0f183ab26ca', 'dsc md5 hash';

my ($tgz) = grep { $_->{Type} eq 'tar' } @{ $sa->{Files} };

like $tgz->{ArchiveURI}, qr{ pool/main/a/a/a_0\.1\.tar\.gz \z}mx, 'tgz uri';
is   $tgz->{MD5Hash}, 'a54a02be45314a8eea38058b9bbea7da', 'tgz md5 hash';

done_testing;
