package Device::Inverter::KOSTAL::PIKO::LogdataRecord;

use 5.01;
use strict;
use utf8;
use warnings;

our $VERSION = '0.01';

use Any::Moose;
use Device::Inverter::KOSTAL::PIKO::Timestamp;
use namespace::clean -except => 'meta';

has inverter => (
    is       => 'ro',
    isa      => 'Device::Inverter::KOSTAL::PIKO',
    required => 1,
);

has logdata => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has timestamp => (
    is  => 'rw',
    isa => 'Device::Inverter::KOSTAL::PIKO::Timestamp',
);

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
