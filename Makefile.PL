use strict;
use warnings;
use inc::Module::Install;
use Module::Install::AuthorRequires;
use Module::Install::AuthorTests;
use Module::Install::Authority;

all_from 'lib/Log/Stash/Syslog.pm';

license 'perl';
authority 'GHENRY';

requires 'Moose';
requires 'namespace::autoclean';
requires 'AnyEvent';
requires 'POE::Component::Server::Syslog::UDP';
requires 'JSON';
requires 'JSON::XS';
requires 'Try::Tiny';
requires 'Task::Weaken';
requires 'Log::Stash' => '0.002';

test_requires 'Test::More' => '0.88';

author_requires 'Test::Pod' => '1.14';
author_requires 'Test::NoTabs';
author_requires 'Test::Pod::Coverage' => '1.04';
author_requires 'Pod::Coverage' => '0.19';
author_requires 'Pod::Coverage::TrustPod';
author_requires 'Test::Spelling';

author_tests 't/author';

if ($Module::Install::AUTHOR) {
    system("pod2text lib/Log/Stash/Input/Syslog.pm > README")
        and die $!;
}

WriteAll;

