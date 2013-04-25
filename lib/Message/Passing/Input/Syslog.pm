package Message::Passing::Input::Syslog;
use Moo;
use MRO::Compat;
use Time::ParseDate;
use Socket qw( getnameinfo NI_NUMERICHOST  NI_NUMERICSERV );
use Parse::Syslog::Line qw( parse_syslog_line );

# for speed, we don't need the created DateTime object
$Parse::Syslog::Line::DateTimeCreate = 0;

use namespace::clean -except => 'meta';

extends 'Message::Passing::Input::Socket::UDP';

has '+port' => (
    default => sub { 5140 },
    required => 0,
);

has protocol => (
    is => 'ro',
    default => sub { 'udp' },
);

has remote_hostname => (
    is => 'ro',
    default => sub { 0 },
);

sub BUILD {
    my $self = shift;
    die sprintf("Protocol '%s' is not supported, only 'udp' currently", $self->protocol)
        if $self->protocol ne 'udp';
}

sub _send_data {
    my ( $self, $message, $from ) = @_;

    my $msg = parse_syslog_line( $message );
    my $time = defined $msg->{datetime_raw} ? parsedate($msg->{datetime_raw}) : undef;
    $msg->{epochtime} = $time || time();
    $self->output_to->consume( $msg );
}

1;

=head1 NAME

Message::Passing::Input::Syslog - input messages from Syslog.

=head1 SYNOPSIS

    message-pass --input Syslog --input_options '{"port":"5140"}' --output STDOUT

=head1 DESCRIPTION

Provides a syslog server for UDP syslog.

Can be used to ship syslog logs into a L<Message::Passing> system.

For the message format see L<Parse::Syslog::Line>.

=head1 ATTRIBUTES

=head2 hostname

The IP to bind the daemon to. By default, binds to 127.0.0.1, which
means that the server can only be accessed from localhost. Use C<0.0.0.0>
to bind to all interfaces.

=head2 port

The port to bind to, defaults to 5140, as the default syslog port (514)
is likely already taken by your regular syslogd, and needs root permissio
to bind to it.

=head2 protocol

The protocol to listen on, currently only UDP is supported.

=head2 remote_hostname

Set to true to store the remote ip address instead of the servers' hostname
in the hostname attribute.
Defaults to false for backward compatibility.

=head1 SEE ALSO

=over

=item L<Message::Passing::Syslog>

=item L<Message::Passing>

=back

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing::Syslog>.

=cut
