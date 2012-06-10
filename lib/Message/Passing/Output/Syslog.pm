package Message::Passing::Output::Syslog;
use Moose;
use Moose::Util::TypeConstraints;
use AnyEvent;
use Scalar::Util qw/ weaken /;
use Try::Tiny qw/ try catch /;
use Sys::Hostname::Long qw/ hostname_long /;
use namespace::autoclean;

my $hostname = hostname_long();

with qw/
    Message::Passing::Role::Output
    Message::Passing::Role::HasHostnameAndPort
/;

has '+hostname' => (
    default => '127.0.0.1',
);

sub _default_port { 5140 }

has protocol => (
    isa => enum([qw/ tcp udp /]),
    is => 'ro',
    default => 'udp',
);

my %syslog_severities = do { my $i = 0; map { $i++ => $_ } (qw/
    emergency
    alert
    critical
    error
    warning
    notice
    informational
    debug
/) };

my %syslog_facilities = do { my $i = 0; map { $i++ => $_ } (qw/
    kernel
    user
    mail
    daemon
    auth
    syslog
    lpr
    news
    uucp
    cron
    authpriv
    security2
    ftp
    NTP
    audit
    alert
    clock2
    local0
    local1
    local2
    local3
    local4
    local5
    local6
    local7
/) };

sub BUILD {
    my $self = shift;
    die "Not implemented";
}

1;

=head1 NAME

Message::Passing::Output::Syslog - output messages to Syslog.

=head1 SYNOPSIS

    message-pass --output STDOUT --output Syslog --output_options '{"hostname":"127.0.0.1","port":"5140"}'

=head1 DESCRIPTION

B<NOTE> This module is not currently functional!

Provides a syslogd client.

Can be used to ship syslog logs from a L<Message::Passing> system.

=head1 ATTRIBUTES

=head2 hostname

The hostname to connect to

=head2 port

The port to connect to, defaults to 5140.

=head2 protocol

The protocol to send messages on, can be either C<tcp> or C<udp>, with udp being
the default.

=head1 SEE ALSO

=over

=item L<Message::Passing::Syslog>

=item L<Message::Passing>

=back

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing::Syslog>.

=cut


