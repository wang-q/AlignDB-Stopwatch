use strict;
use warnings;
use Test::More;
use Test::Output;

use AlignDB::Stopwatch;

my $stopwatch = AlignDB::Stopwatch->new;

$stopwatch->start_time(time);
stdout_like(
    sub { $stopwatch->start_message },
    qr{\=+\nStart[\w:. ]+\n\n}
);

$stopwatch->start_time(time);
stdout_like(
    sub { $stopwatch->start_message("Hello") },
    qr{\=+\nHello\nStart[\w:. ]+\n\n}
);

$stopwatch->start_time(time);
stdout_like(
    sub { $stopwatch->start_message("Hello", 1) },
    qr{\=+Hello\=+\nStart[\w:. ]+\n\n}
);

$stopwatch->start_time(time);
stdout_like(
    sub { $stopwatch->end_message },
    qr{\nEnd[\w:. ]+\n[\w:. ]+\n\=+\n}
);

done_testing(4);
