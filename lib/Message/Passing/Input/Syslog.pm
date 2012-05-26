package Message::Passing::Input::Syslog;
use Moose;
use Moose::Util::TypeConstraints;
use POE::Component::Server::Syslog::UDP;
use POE::Component::Server::Syslog::TCP;
BEGIN { $ENV{PERL_ANYEVENT_MODEL} = "POE" }
use AnyEvent;
use Scalar::Util qw/ weaken /;
use Try::Tiny qw/ try catch /;
use Sys::Hostname::Long qw/ hostname_long /;
use namespace::autoclean;

my $hostname = hostname_long();

with qw/
    Message::Passing::Role::Input
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

my %server_class = (
    udp => 'POE::Component::Server::Syslog::UDP',
    tcp => 'POE::Component::Server::Syslog::TCP',
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

sub _start_syslog_listener {
    my $self = shift;
    weaken($self);
    $server_class{$self->protocol}->spawn(
        BindAddress => $self->host,
        BindPort    => $self->port,
        InputState  => sub {
            my $message = pop(@_);
            $message->{message} = delete($message->{msg});
            $message->{epochtime} = delete($message->{time}) || time();
            delete($message->{$_}) for qw/ addr host /;
            $message->{hostname} = $hostname;
            $message->{priority_code} = delete($message->{pri});
            my $severity = delete($message->{severity});
            $message->{severity} = $syslog_severities{$severity};
            $message->{severity_code} = $severity;
            my $fac = delete($message->{facility});
            $message->{facility} = $syslog_facilities{$fac} || 'unknown';
            $message->{facility_code} = $fac;
           # FIXME - Turn integer priority / facility etc into
            #         strings here!
            $self->output_to->consume($message);
        },
    );
}

sub BUILD {
    my $self = shift;
    $self->_start_syslog_listener;
}

1;

=head1 NAME

Message::Passing::Input::Syslog - input logstash messages from Syslog.

=head1 SYNOPSIS

    logstash --output STDOUT --input Syslog --input_options '{"port":"5140"}'

=head1 DESCRIPTION

Provides a syslogd server for either TCP or UDP syslog.

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


