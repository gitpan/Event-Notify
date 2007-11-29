use strict;
use inc::Module::Install;

name("Event-Notify");
all_from('lib/Event/Notify.pm');
requires('Carp');

build_requires('Test::More');
build_requires('Test::MockObject');

auto_install;
WriteAll;