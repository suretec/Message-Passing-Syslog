package Log::Stash::Syslog;
use strict;
use warnings;
BEGIN { $ENV{PERL_ANYEVENT_MODEL} = "POE" }

our $VERSION = '0.001';

1;

=head1 NAME

Log::Stash::Syslog - input and output logstash messages from/to Syslog.

=head1 SYNOPSIS

    logstash --output STDOUT --input Syslog --input_options '{"port":"5140"}'

    logstash --input STDIN --output Syslog --output_options 'xxx'

=head1 DESCRIPTION

Provides a syslogd server and client for either TCP or UDP syslog.

=head1 SEE ALSO

=over

=item L<Log::Stash::Input::Syslog>

=item L<Log::Stash::Output::Syslog>

=back

=head1 AUTHOR and COPYRIGHT

Tomas Doran

=head1 LICENSE

Same terms as perl itself.

=cut


