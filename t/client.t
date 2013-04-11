use strict;
use warnings;
use Test::More;

BEGIN {
    do { local $@; eval { require Net::Syslog } }
        || plan skip_all => "Net::Syslog needed for this test";
}

use Sys::Hostname::Long qw/ hostname_long /;
use Message::Passing::Output::Syslog;
use Message::Passing::Input::Syslog;
use Message::Passing::Output::Callback;
use AnyEvent;

my $cv = AnyEvent->condvar;

my $syslog = Message::Passing::Output::Syslog->new(
    hostname => '127.0.0.1',
    port     => '5140',
);

my @msgs;
my $l = Message::Passing::Input::Syslog->new(
    output_to => Message::Passing::Output::Callback->new(
        cb => sub {
            push(@msgs, shift());
            $cv->send;
        },
    ),
);

my $idle; $idle = AnyEvent->idle(cb => sub {
    $syslog->consume("foo");
    undef $idle;
});

$cv->recv;

ok scalar(@msgs);
my $time = delete $msgs[0]->{epochtime};
like $time, qr/^\d+$/;

is_deeply \@msgs, [
    {
        'hostname' => hostname_long(),
        'message' => "client.t[$$]: foo",
        'facility' => 'local4',
        'severity' => 'error',
        'severity_code' => 3,
        'facility_code' => 21
    }
];

done_testing;

