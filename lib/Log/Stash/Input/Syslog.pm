package Log::Stash::Input::Syslog;
use Moose;
use POE::Component::Server::Syslog::UDP;
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

sub _start_syslog_listener {
    my $self = shift;
    weaken($self);
    POE::Component::Server::Syslog::UDP->spawn(
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

=head1 DESCRIPTION

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


