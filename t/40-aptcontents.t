use t::boilerplate;

use Test::More;
use English               qw( -no_match_vars );
use File::Spec::Functions qw( catfile );
use File::Touch           qw( touch );
use FindBin               qw( $Bin );

use_ok 'Debian::AptContents';

unlink catfile( $Bin, 'Contents.cache' );

sub instance {
   Debian::AptContents->new( {
      contents_dir => catfile( $Bin, 'contents' ),
      homedir      => $Bin,
      sources      => catfile( $Bin, 'contents', 'sources.list' ),
      verbose      => 0,
      @_,
   } );
}

eval { Debian::AptContents->new() };

ok   $EVAL_ERROR, 'AptContents->new with no homedir dies';
like $EVAL_ERROR, qr{ \QNo homedir given\E }mx, 'Should say why it died';

my $apt_contents = instance( contents_dir => 'non-existent' );

isnt $apt_contents, undef, 'Should create with no contents';

is $apt_contents->cache, undef, 'Should contain no cache';

is $apt_contents->cache, undef, 'Should have no cache when no dists found';

is_deeply
   [  $apt_contents->repo_source_to_contents_paths
        ( 'deb     http://debian.cihar.com/ unstable main contrib non-free' ) ],
   [  'debian.cihar.com_dists_unstable_main',
      'debian.cihar.com_dists_unstable_contrib',
      'debian.cihar.com_dists_unstable_non-free',
      'debian.cihar.com_dists_unstable', ],
   'Source line conversion 1';

is_deeply(
    [ $apt_contents->repo_source_to_contents_paths(
        'deb     http://kernel-archive.buildserver.net/debian-kernel trunk main') ],
    [ 'kernel-archive.buildserver.net_debian-kernel_dists_trunk_main',
     'kernel-archive.buildserver.net_debian-kernel_dists_trunk' ],
    'source line conversion 2',
);

is_deeply(
    [ $apt_contents->repo_source_to_contents_paths(
        'deb     http://www.debian-multimedia.org stable main') ],
    [ 'www.debian-multimedia.org_dists_stable_main',
      'www.debian-multimedia.org_dists_stable' ],
    'source line conversion 3',
);

is_deeply(
    [ $apt_contents->repo_source_to_contents_paths(
        'deb     http://ftp.debian-unofficial.org/debian testing main contrib non-free restricted') ],
    [ 'ftp.debian-unofficial.org_debian_dists_testing_main',
      'ftp.debian-unofficial.org_debian_dists_testing_contrib',
      'ftp.debian-unofficial.org_debian_dists_testing_non-free',
      'ftp.debian-unofficial.org_debian_dists_testing_restricted',
      'ftp.debian-unofficial.org_debian_dists_testing' ],
    'source line conversion 4',
);

is_deeply(
    [ $apt_contents->repo_source_to_contents_paths(
        'deb     http://ftp.de.debian.org/debian/ unstable main contrib non-free') ],
    [ 'ftp.de.debian.org_debian_dists_unstable_main',
      'ftp.de.debian.org_debian_dists_unstable_contrib',
      'ftp.de.debian.org_debian_dists_unstable_non-free',
      'ftp.de.debian.org_debian_dists_unstable' ],
    'source line conversion 5',
);

is_deeply(
    [   $apt_contents->repo_source_to_contents_paths(
            'deb http://user:pass@ftp2.de.debian.org/debian/ squeeze main contrib non-free'
        )
    ],
    [   'ftp2.de.debian.org_debian_dists_squeeze_main',
        'ftp2.de.debian.org_debian_dists_squeeze_contrib',
        'ftp2.de.debian.org_debian_dists_squeeze_non-free',
        'ftp2.de.debian.org_debian_dists_squeeze',
    ],
    'source lines with user:pass@',
);

is_deeply(
    [ $apt_contents->repo_source_to_contents_paths(
        'deb file:/home/jason/debian stable main contrib non-free') ],
    [ '_home_jason_debian_dists_stable_main',
      '_home_jason_debian_dists_stable_contrib',
      '_home_jason_debian_dists_stable_non-free',
      '_home_jason_debian_dists_stable' ],
    'source line conversion 6',
);

$apt_contents = instance();

is_deeply(
    $apt_contents->contents_files,
    [ sort grep { not m{ Contents.cache }mx }
      glob catfile( $Bin, 'contents', '*Contents*' ) ],
    'contents in a dir'
);

ok -f catfile( $Bin, 'Contents.cache' ), 'Contents.cache created';

is $apt_contents->source, 'parsed files', 'no cache was used';

$apt_contents = instance();

is $apt_contents->source, 'cache', 'cache was used';

sleep( 1 );   # allow the clock to tick so the timestamp actually differs
touch( glob catfile( $Bin, 'contents', '*Contents*' ) );

$apt_contents = instance();

is( $apt_contents->source, 'parsed files', 'cache updated' );

is_deeply(
    [ $apt_contents->find_file_packages('Moose.pm')],
    [ 'libmoose-perl' ],
    'Moose found by find_file_packages' );

is( $apt_contents->find_perl_module_package('Moose') . '',
    'libmoose-perl', 'Moose found by module name' );

is_deeply(
    $apt_contents->get_contents_files,
    [   "$Bin/contents/test_debian_dists_sid_main_Contents",
        "$Bin/contents/test_debian_dists_testing_main_Contents"
    ]
);

is_deeply(
    [ $apt_contents->find_file_packages('GD.pm') ],
    [ 'libgd-gd2-noxpm-perl', 'libgd-gd2-perl' ],
    "GD.pm is in libdg-gd2[-noxpm]-perl"
);

is( $apt_contents->find_perl_module_package('GD') . '',
    'libgd-gd2-noxpm-perl | libgd-gd2-perl',
    'Alternative dependency for module found in multiple packages'
);

is_deeply(
    [ $apt_contents->find_file_packages('Image/Magick.pm') ],
    [ 'perlmagick', 'graphicsmagick-libmagick-dev-compat' ],
    "Image/Magick.pm in perlmagick and graphicsmagick-libmagick-dev-compat, but different paths"
);

is( $apt_contents->find_perl_module_package('Image::Magick') . '',
    'graphicsmagick-libmagick-dev-compat | perlmagick',
    'Alternative dependency for Image::Magick module found in multiple packages'
);

ok unlink catfile( $Bin, 'Contents.cache' ), 'Contents.cache unlnked';

done_testing;

