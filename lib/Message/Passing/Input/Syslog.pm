package Message::Passing::Input::Syslog;
use Moo;
use MRO::Compat;
use Time::ParseDate;
use Sys::Hostname::Long qw/ hostname_long /;
use namespace::clean -except => 'meta';

my $hostname = hostname_long();

extends 'Message::Passing::Input::Socket::UDP';

has '+port' => (
    default => sub { 5140 },
    required => 0,
);

has protocol => (
    is => 'ro',
    default => sub { 'udp' },
);

our $SYSLOG_REGEXP = q|
^<(\d+)>                       # priority -- 1
    (?:
        (\S{3})\s+(\d+)        # month day -- 2, 3
        \s
        (\d+):(\d+):(\d+)      # time  -- 4, 5, 6
    )?
    \s*
    (.*)                       # text  --  7
$
|;

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
    die sprintf("Protocol '%s' is not supported, only 'udp' currently", $self->protocol)
        if $self->protocol ne 'udp';
}

sub _send_data {
    my ( $self, $message, $from ) = @_;
    if ( $message =~ s/$SYSLOG_REGEXP//sx ) {
        my $time = $2 && parsedate("$2 $3 $4:$5:$6");
        my $facility = int($1/8);
        my $severity = int($1%8);
        $self->output_to->consume({
            epochtime     => $time || time(),
            facility_code => $facility,
            severity_code => $severity,
            facility => $syslog_facilities{$facility} || 'unknown',
            severity => $syslog_severities{$severity} || 'unknown',
            message      => $7,
            hostname => $hostname,
        });
    }
}

1;

=head1 NAME

Message::Passing::Input::Syslog - input messages from Syslog.

=head1 SYNOPSIS

    message-pass --output STDOUT --input Syslog --input_options '{"hostna

=head1 DESCRIPTION

Provides a syslogd server for either TCP or UDP syslog.

Can be used to ship syslog logs into a L<Message::Passing> system.

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

=head1 SEE ALSO

=over

=item L<Message::Passing::Syslog>

=item L<Message::Passing>

=back

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing::Syslog>.

=cut
