#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

my $rs = $schema->resultset('Foo');

cmp_deeply
   [$rs->group_by(['me.id'])->all],
   [$rs->search(undef,{group_by => ['me.id']})->all],
   'group_by works the same';

done_testing;
