package Device::Inverter::KOSTAL::PIKO;

use strict;
use utf8;
use warnings;

our $VERSION = '0.01';

use Any::Moose;
use Carp qw(carp confess croak);
use Params::Validate qw(validate_pos);
use Scalar::Util qw(openhandle);
use namespace::clean -except => 'meta';

has configfile => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        require File::HomeDir;
        require File::Spec;
        File::Spec->catfile( File::HomeDir->my_home, '.pikorc' );
    }
);

has name => (
    is  => 'rw',
    isa => 'Str',
);

has number => (
    is  => 'rw',
    isa => 'Int',
);

has time_offset => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->read_configfile;
        confess('time_offset not set') unless $self->has_time_offset;
        $self->time_offset;
    },
    predicate => 'has_time_offset',
);

sub configure {
    my ( $self, $config_subhash ) = @_;
    while ( my ( $attr, $data ) = each %$config_subhash ) {
        my $has_attr = "has_$attr";
        $self->$attr($data) unless $self->$has_attr;
    }
}

sub load {
    my $self = shift;
    my ($source) = validate_pos( @_, 1 );
    my %param = ( inverter => $self );
    unless ( ref $source ) {    # String => filename
        open $param{fh}, '<', $param{filename} = $source
          or croak(qq(Cannot open file "$source" for reading: $!));
    }
    elsif ( openhandle $_) { $param{fh} = $source }
    else {
        open $param{fh}, '<', $source
          or croak(qq(Cannot open reference for reading: $!));
    }
    require Device::Inverter::KOSTAL::PIKO::File;
    Device::Inverter::KOSTAL::PIKO::File->new(%param);
}

sub read_configfile {
    my $self       = shift;
    my $configfile = $self->configfile;
    carp(qq(Config file "$configfile" not found)) unless -e $configfile;
    require Config::INI::Reader;
    my $config_hash = Config::INI::Reader->read_file($configfile);

    if ( defined( my $number = $self->number ) ) {
        if ( defined( my $specific_config = $config_hash->{$number} ) ) {
            $self->configure($specific_config);
        }
    }
    if ( defined( my $general_config = $config_hash->{_} ) ) {
        $self->configure($general_config);
    }
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__
=head1 NAME

Device::Inverter::KOSTAL::PIKO - class which represents a KOSTAL PIKO DC/AC converter

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

    use Device::Inverter::KOSTAL::PIKO;

    my $piko = Device::Inverter::KOSTAL::PIKO->new( time_offset => 1309160816 );
    my $file = $piko->load($filename_or_handle_or_ref_to_data);
    say $_->timestamp for $file->logdata;

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head1 AUTHOR

Martin H. Sluka, C<< <fany at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-device-inverter-kostal-piko at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Device-Inverter-KOSTAL-PIKO>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Device::Inverter::KOSTAL::PIKO


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Device-Inverter-KOSTAL-PIKO>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Device-Inverter-KOSTAL-PIKO>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Device-Inverter-KOSTAL-PIKO>

=item * Search CPAN

L<http://search.cpan.org/dist/Device-Inverter-KOSTAL-PIKO/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Martin H. Sluka.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
