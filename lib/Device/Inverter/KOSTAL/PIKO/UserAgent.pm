package Device::Inverter::KOSTAL::PIKO::UserAgent;

use strict;
use utf8;
use warnings;

our $VERSION = '0.01';

use base 'LWP::UserAgent';

use Any::Moose;
use namespace::clean -except => 'meta';

has $_ => ( isa => 'Str', is => 'rw', required => 1 ) for qw(password username);

sub get_basic_credentials {
    my $self = shift;
    $self->username, $self->password;
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
