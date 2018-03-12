#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Deep;

use TestSchema;
my $schema = TestSchema->deploy_or_connect();
$schema->prepopulate;

RemoveColumns: {
   my $rs = $schema->resultset('Foo')->search({
      id => 1
   }, {
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
      'remove_columns' => ['bar_id'],
   });

   cmp_deeply [$rs->all], [{ id => 1 }], 'remove_columns works';

   cmp_deeply
      [$rs->search({ id => { '!=' => 4 } })->all],
      [{ id => 1 }],
      'chaining remove_columns works';;

   cmp_deeply
      [
         $rs->search({
            id => { '!=' => 4 }
         }, {
            '+columns' => 'bar_id'
         })->all
      ],
      [{ bar_id => 1, id => 1 }],
      'chaining and +columns works with remove_columns';
}

AutoRemoveColumns: {
   my $rs = $schema->resultset('Bloaty')->search({
      id => 1
   }, {
      result_class => 'DBIx::Class::ResultClass::HashRefInflator',
   });

   cmp_deeply [$rs->all], [{ id => 1 }], 'remove_columns works';

   cmp_deeply
      [$rs->search({ id => { '!=' => 4 } })->all],
      [{ id => 1 }],
      'chaining remove_columns works';;

   cmp_deeply
      [
         $rs->search({
            id => { '!=' => 4 }
         }, {
            '+columns' => 'name'
         })->all
      ],
      [{ name => 1, id => 1 }],
      'chaining and +columns works with remove_columns';

   my $prefetch = $schema->resultset('Gnarly_Station')->search({}, {
    prefetch => 'gnarly',
    order_by => 'id',
    rows => 1
   });
   cmp_deeply
      [
        { $prefetch->single->gnarly->get_columns }
      ],
      [{ id => 1, name => 'frew' }],
      'Prefetching a linked table should not include removed columns';
}

done_testing;
