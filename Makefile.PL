
use ExtUtils::MakeMaker;
use Carp;

my $mm_version = $ExtUtils::MakeMaker::VERSION || $ExtUtils::MakeMaker::Version;
if ( $mm_version < 3.5 ) {
    croak("Sorry, but MakeMaker 3.5 or better is needed to build this package.");
}

&WriteMakefile(
    NAME       => 'Term::ReadKey',
    DISTNAME   => 'TermReadKey',
    LICENSE    => 'perl',
    ABSTRACT   => 'Change terminal modes, and perform non-blocking reads.',
    AUTHOR     => ['Kenneth Albanowski','Jonathan Stowe'],
    META_MERGE => {
        no_index  => {
            file     => [ qw(Configure.pm) ],
            package  => [ qw(Configure) ],
        },
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/jonathanstowe/TermReadKey.git',
                web  => 'https://github.com/jonathanstowe/TermReadKey',
            },
        },
    },
    VERSION_FROM => 'ReadKey_pm.PL',
    XSPROTOARG   => '-noprototypes',
    PL_FILES	 => { 'ReadKey_pm.PL' => 'ReadKey.pm' },
    PM           => { 'ReadKey.pm' => '$(INST_ARCHLIBDIR)/ReadKey.pm' },
    clean        => { FILES => 'cchars.h ReadKey.pm' },
    SIGN => 1,

    # Uncomment these to allow testing of sgtty under Linux. Not needed normally.
    # INC => "-I/usr/include/bsd",
    # LIBS => "-lbsd"
);

sub MY::top_targets {
    my $self = shift;
    $_ = $self->MM::top_targets();
    # ensure that the XS is built before the PM
    s/pure_all :: config pm_to_blib (.* )linkext/pure_all :: config linkext pm_to_blib $1/;

    $_ .= "

sgtty cchars.h: genchars.pl
	\$(PERLRUN) genchars.pl

distcc: genchars.pl
	\$(PERLRUN) genchars.pl dist

ReadKey.c: cchars.h

";
    $_
}

sub MY::test {
    my $self = shift;
    $_ = $self->MM::test();
    s#example/test.pl#-w example/test.pl#;
    $_
}

sub MY::test_interactive {
    "Fooo"
}

sub MY::pure_site_install {
    my $self = shift;
    my $new = $self->MM::test();

    $new .= "\n\t./register_module Term::ReadKey";
    $new
}
