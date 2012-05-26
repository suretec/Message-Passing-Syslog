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
/;

has host => (
    isa => 'Str',
    is => 'ro',
    default => '127.0.0.1',
);

has port => (
    isa => 'Int',
    required => 1,
    is => 'ro',
    default => 5140,
);

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

Message::Passing::Output::Syslog - output logstash messages to Syslog.

=head1 SYNOPSIS

    logstash --output STDOUT --output Syslog --output_options '{"port":"5140"}'

=head1 DESCRIPTION

Provides a syslogd client.

Can be used to ship syslog logs into a L<Message::Passing> system.

=head1 ATTRIBUTES

=head2 host

The IP to bind the daemon to. By default, binds to 127.0.0.1, which
means that the server can only be accessed from localhost. Use C<0.0.0.0>
to bind to all interfaces.

=head2 port

The port to bind to, defaults to 5140, as the default syslog port (514)
is likely already taken by your regular syslogd, and needs root permission
to bind to it.

=head2 protocol

The protocol to listen on, can be either C<tcp> or C<udp>, with udp being
the default.

=head1 SEE ALSO

=over

=item L<Message::Passing::Syslog>

=item L<Message::Passing>

=back

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing::Syslog>.

=cut


