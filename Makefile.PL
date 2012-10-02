use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Device::Inverter::KOSTAL::PIKO',
    AUTHOR              => q{Martin H. Sluka <fany@cpan.org>},
    VERSION_FROM        => 'lib/Device/Inverter/KOSTAL/PIKO.pm',
    ABSTRACT_FROM       => 'lib/Device/Inverter/KOSTAL/PIKO.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Device-Inverter-KOSTAL-PIKO-*' },
);
