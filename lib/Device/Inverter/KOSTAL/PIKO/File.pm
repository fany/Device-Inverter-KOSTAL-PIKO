package Device::Inverter::KOSTAL::PIKO::File;

use 5.01;
use strict;
use utf8;
use warnings;

our $VERSION = '0.01';

use Any::Moose;
use Carp qw(carp confess);
use Device::Inverter::KOSTAL::PIKO::LogdataRecord;
use Device::Inverter::KOSTAL::PIKO::Timestamp;
use namespace::clean -except => 'meta';

has columns => (
    is  => 'rw',
    isa => 'ArrayRef[Str]',
);

has fh => (
    is       => 'ro',
    isa      => 'FileHandle',
    required => 1,
);

has filename => (
    is  => 'ro',
    isa => 'Str',
);

has inverter => (
    is       => 'ro',
    isa      => 'Device::Inverter::KOSTAL::PIKO',
    required => 1,
);

has logdata => (
    is  => 'rw',
    isa => 'ArrayRef[Device::Inverter::KOSTAL::PIKO::LogdataRecord]',
);

has timestamp => (
    is  => 'rw',
    isa => 'Device::Inverter::KOSTAL::PIKO::Timestamp',
);

sub BUILD {
    my $self = shift;

    # Parse file:
    my %logdata;
    while ( defined( my $line = $self->getline ) ) {
        for ($line) {

            # Wechselricher Logdaten
            when (/^Wechselrich?er Logdaten$/) {    # parse file header
                {                                   # Wechselrichter Nr:	255
                    my ( $line, %c ) =
                      $self->getline_expect(
                        qr/^Wechselrichter Nr:\s+(?<nr>\d+)$/);
                    unless ( defined( my $nr = $self->inverter->number ) ) {
                        $self->inverter->number( $c{nr} );
                    }
                    elsif ( $nr != $c{nr} ) {
                        carp(
                            $self->errmsg(
                                "Conflicting inverter numbers: $nr vs. $c{nr}")
                        );
                    }
                }
                {    # Name:	piko
                    my ( $line, %c ) =
                      $self->getline_expect(qr/^Name:\s+(?<name>.*?)\s*$/);
                    unless ( defined( my $nr = $self->inverter->name ) ) {
                        $self->inverter->name( $c{name} );
                    }
                    elsif ( $nr != $c{name} ) {
                        carp(
                            $self->errmsg(
                                    'Conflicting inverter names: '
                                  . qq("$nr" vs. "$c{nr}")
                            )
                        );
                    }
                }
                {    # akt. Zeit:	  12345678
                    my ( $line, %c ) =
                      $self->getline_expect(qr/^akt\. Zeit:\s+(?<zeit>\d+)$/);
                    $self->set_timestamp( $c{zeit} );
                }
                $self->getline_expect('');
            }

   # Logdaten U[V], I[mA], P[W], E[kWh], F[Hz], R[kOhm], Ain T[digit], Zeit[sec]
            when (/^Logdaten (.*)$/) {
                for ( split /, /, $1 ) {
                    /^([^\[]+)\[(\w+)\]$/
                      or $self->errmsg(qq(Unknown unit spec "$_"));

                    # further parsing and usage of units not yet implemented
                }
            }

# Zeit	DC1 U	DC1 I	DC1 P	DC1 T	DC1 S	DC2 U	DC2 I	DC2 P	DC2 T	DC2 S	DC3 U	DC3 I	DC3 P	DC3 T	DC3 S	AC1 U	AC1 I	AC1 P	AC1 T	AC2 U	AC2 I	AC2 P	AC2 T	AC3 U	AC3 I	AC3 P	AC3 T	AC F	FC I	Ain1	Ain2	Ain3	Ain4	AC S	Err	ENS S	ENS Err	KB S	total E	Iso R	Ereignis
            when (/^Zeit\t(?:(?:[\w ]+)\t)+$/) {
                $self->columns( split /\t/ );
            }

#   40094373	   466	  1070	   483	49402	16393	   543	   520	   287	49421	49162	     0	    20	     0	49412	    3	   224	  1880	   409	49927	   223	  1100	   240	49911	   223	   230	    50	49892	50.0	    1	    0	    0	    0	    0	   28	    0	  3	    0
            when (/^(?=[ 0-9]{10}\t) *([1-9][0-9]*)\t/) {
                push @{ $logdata{$1} }, $_
            }
        }
    }

    $self->logdata(
        [
            map Device::Inverter::KOSTAL::PIKO::LogdataRecord->new(
                inverter  => $self->inverter,
                logdata   => $logdata{$_},
                timestamp => Device::Inverter::KOSTAL::PIKO::Timestamp->new(
                    inverter => $self->inverter,
                    epoch    => $_,
                ),
            ),
            sort { $a <=> $b } keys %logdata
        ]
    );
}

sub errmsg {
    my $self     = shift;
    my $message  = shift // 'Unexpected error';
    my $filename = $self->filename;
    "$message at line $." . ( defined $filename && qq( of file "$filename") );
}

sub getline($) {
    my $self = shift;
    my $fh   = $self->fh;
    my $line = <$fh>;
    $line =~ s/\cM?\cJ\z// if defined $line;
    $line;
}

sub getline_expect($) {
    my ( $self, $expectation ) = @_;
    defined( my $line = $self->getline )
      or confess( $self->errmsg('Unexpected EOF') );
    confess( $self->errmsg(qq(Unexpected content: "$line")) )
      if ref($expectation) ? $line !~ $expectation : $line ne $expectation;
    if (wantarray) { $line, %+ }
    else           { $line }
}

sub set_timestamp {
    my ( $self, $timestamp ) = @_;
    $self->timestamp(
        Device::Inverter::KOSTAL::PIKO::Timestamp->new(
            inverter => $self->inverter,
            epoch    => $timestamp,
        )
    );
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
