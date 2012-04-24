package Log::Stash::Input::Syslog;
use Moose;
use POE::Component::Server::Syslog::UDP;
use POE::Component::Server::Syslog::TCP;
BEGIN { $ENV{PERL_ANYEVENT_MODEL} = "POE" }
use AnyEvent;
use Scalar::Util qw/ weaken /;
use Try::Tiny qw/ try catch /;
use Sys::Hostname::Long qw/ hostname_long /;
use namespace::autoclean;

our $VERSION = '0.001';

my $hostname = hostname_long();

with qw/
    Log::Stash::Role::Input
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

sub _start_syslog_listener {
    my $self = shift;
    weaken($self);
    $server_class{$self->protocol}->spawn(
        BindAddress => $self->host,
        BindPort    => $self->port,
        InputState  => sub {
            my $message = pop(@_);
            $message->{message} = delete($message->{msg});
            $message->{epochtime} = delete($message->{time});
            delete($message->{$_}) for qw/ addr host /;
            $message->{hostname} = $hostname;
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

Log::Stash::Input::Syslog - input logstash messages from Syslog.

=head1 SYNOPSIS

    logstash --output STDOUT --input Syslog --input_options '{"port":"5140"}'

=head1 DESCRIPTION

Provides a syslogd server for either TCP or UDP syslog.

Can be used to ship syslog logs into a L<Log::Stash> system.

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

=item L<Log::Stash::Syslog>

=item L<Log::Stash>

=back

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored it's development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut


