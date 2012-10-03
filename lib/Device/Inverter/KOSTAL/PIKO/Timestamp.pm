package Device::Inverter::KOSTAL::PIKO::Timestamp;

use 5.01;
use strict;
use utf8;
use warnings;

our $VERSION = '0.01';

use Any::Moose;
use namespace::clean -except => 'meta';

has inverter => (
    is       => 'ro',
    isa      => 'Device::Inverter::KOSTAL::PIKO',
    required => 1,
);

has epoch => (
    is  => 'ro',
    isa => 'Int',
);

has datetime => (
    is      => 'ro',
    isa     => 'DateTime',
    lazy    => 1,
    default => sub {
        my $self = shift;
        require DateTime;
        DateTime->from_epoch(
            epoch => $self->inverter->time_offset + $self->epoch );
    },
);

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
