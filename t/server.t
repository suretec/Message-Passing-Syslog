use strict;
use warnings;
use Test::More;

BEGIN {
    do { local $@; eval { require Net::Syslog } }
        || plan skip_all => "Net::Syslog needed for this test";
}

use Sys::Hostname::Long qw/ hostname_long /;
use Log::Stash::Input::Syslog;
use Log::Stash::Output::Callback;
use Net::Syslog;
use AnyEvent;

my $cv = AnyEvent->condvar;

my $syslog = Net::Syslog->new(
    SyslogPort => 5140,
);

my @msgs;
my $l = Log::Stash::Input::Syslog->new(
    output_to => Log::Stash::Output::Callback->new(
        cb => sub {
            push(@msgs, shift());
            $cv->send;
        },
    ),
);

my $idle; $idle = AnyEvent->idle(cb => sub {
    $syslog->send("foo");
    undef $idle;
});

$cv->recv;

ok scalar(@msgs);
is_deeply \@msgs, [
    {
        'epochtime' => undef,
        'hostname' => hostname_long(),
        'pri' => '171',
        'severity' => 3,
        'message' => "server.t[$$]: foo",
        'facility' => 21
    }
];

#use Data::Dumper;
#warn Dumper(\@msgs);

done_testing;

