use strict;
use warnings;
use Test::More;

use AlignDB::Stopwatch;

my $stopwatch = AlignDB::Stopwatch->new;

is(ref $stopwatch, 'AlignDB::Stopwatch');

ok($stopwatch->start_time =~ /^\d+$/);
ok($stopwatch->uuid =~ /^[\w-]+$/);

done_testing(3);
